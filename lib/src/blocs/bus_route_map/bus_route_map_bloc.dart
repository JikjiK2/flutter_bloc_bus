import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_project/src/blocs/bus_location/bus_location_event.dart';
import 'package:flutter_project/src/blocs/bus_location/bus_location_item.dart';
import 'package:flutter_project/src/blocs/bus_route_map/bus_route_map_event.dart';
import 'package:flutter_project/src/blocs/bus_route_map/bus_route_map_state.dart';
import 'package:flutter_project/src/data/bus_repository.dart';
import 'package:flutter_project/src/data/models/bus_location_info.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart'; // Colors 사용을 위해 import

class BusRouteBloc extends Bloc<BusRouteMapEvent, BusRouteMapState> {
  final BusRepository busRepository; // Repository 인스턴스

  bool _isPollingPaused = false;

  String? _currentCityCode;
  String? _currentRouteId;

  StreamSubscription? _locationInfoSubscription;

  PublishSubject<void> _stopPollingSubject = PublishSubject<void>();
  final PublishSubject<void> _pausePollingSubject = PublishSubject<void>();
  final PublishSubject<void> _resumePollingSubject = PublishSubject<void>();

  BusRouteBloc({required this.busRepository}) : super(BusRouteMapInitial()) {
    on<LoadBusRoute>(_onLoadRouteStops);
    on<RefreshLocationInfo>(_onRefreshLocation);
  }

  @override
  Future<void> close() async {
    _locationInfoSubscription?.cancel();
    _stopPollingSubject.close();
    _pausePollingSubject.close();
    _resumePollingSubject.close();
    print("BusRouteBloc: close() called.");
    return super.close();
  }

  Future<void> _onLoadRouteStops(
    LoadBusRoute event,
    Emitter<BusRouteMapState> emit,
  ) async {
    emit(BusRouteMapLoading());
    try {
      //=======================================
      final stops =
          await busRepository
              .getSelectedAllRouteStops(event.cityCode, event.routeId)
              .first;
      final List<LatLng> points = stops.map((stop) => stop.toLatLng()).toList();

      final Polyline routePolyline = Polyline(
        polylineId: PolylineId(event.routeId),
        // 노선 ID를 Polyline ID로 사용
        points: points,
        // 경로를 구성하는 좌표들
        color: Colors.blue,
        // 경로 선 색상
        width: 5,
        // 경로 선 두께
        geodesic: true, // 지구 곡률을 반영하여 경로를 그릴지 여부
        // 기타 Polyline 속성 설정 가능 (예: jointType, endCap, startCap 등)
      );
      //=======================================

      final Stream<List<BusLocationInfo>> locationInfoPollingStream =
          _createControlledPollingStream(event.cityCode, event.routeId);

      print("BusRouteMap-Location: Created controlled polling stream.");
      return emit.onEach<List<BusLocationInfo>>(
        locationInfoPollingStream,
        onData: (locationInfoList) {
          print(
            "BusRouteMap-Location: Converted Location info list to map. Map size: ${locationInfoList.length}",
          );
          final newState = BusRouteMapLoaded(
            stops: stops,
            routePolyline: routePolyline,
            locationInfoList: locationInfoList,
          );
          print(
            "BusRouteMap-Location: About to emit Loaded state from polling stream data (via onEach): ${newState.runtimeType}",
          );
          emit(newState); // <--- 상태 객체를 emit합니다.

          print(
            "BusRouteMap-Location: Emitted Loaded state from polling stream data.",
          );
        },
        onError: (error, stacktrace) {
          print(
            "BusRouteMap-Location: Stream error during Location info polling (via onEach): $error",
          );
          print("STACKTRACE: $stacktrace");
          final errorState = BusRouteMapError(message: error.toString());
          print("BusRouteMap-Location: About to emit Error state from stream error (via onEach): ${errorState.runtimeType}");
          emit(errorState); // <--- 에러 상태 객체를 emit합니다.
          print("BusRouteMap-Location: Emitted Error state from stream error.");
        },
      );
    } catch (e, stacktrace) {
      print(
        "BusRouteMap-Location: Caught error during initial data fetch or stream setup: $e",
      );
      print("STACKTRACE: $stacktrace");
      emit(BusRouteMapError(message: e.toString())); // 에러 상태
      print("BusRouteMap-Location: Emitted Error state from initial error.");
    }
  }

  Stream<List<BusLocationInfo>> _createControlledPollingStream(
    String cityCode,
    String routeId,
  ) {
    return Stream.periodic(const Duration(seconds: 15))
        .startWith(0) // 즉시 첫 번째 호출
        .takeUntil(_stopPollingSubject)
        .switchMap((_) {
          // pause 상태인지 확인
          if (_isPollingPaused) {
            print("StationRoutesBloc: Polling is paused, skipping API call.");
            return Stream.empty();
          }

          print("StationRoutesBloc: Making API call for arrival info.");
          return busRepository
              .getBusLocationsAll(cityCode, routeId)
              .handleError((error) {
                print("StationRoutesBloc: Error in polling API call: $error");
                throw error;
              });
        });
  }

  Future<void> _onRefreshLocation(
    RefreshLocationInfo event,
    Emitter<BusRouteMapState> emit,
  ) async {
    if (_currentCityCode == null || _currentRouteId == null) {
      print("StationRoutesBloc: Cannot refresh. CityCode or NodeId is null.");
      return;
    }
    emit(
      BusRouteMapLoading(),
    );
    print("StationRoutesBloc: Emitted Loading state for refresh.");

    try {
      final List<BusLocationInfo> locationInfoList =
          await busRepository
              .getBusLocationsAll(_currentCityCode!, _currentRouteId!)
              .first;

      print(
        "StationRoutesBloc: Received ${locationInfoList.length} arrival info items from single API call for refresh.",
      );

      final newState = BusLocationLoaded(
        locationInfoList: locationInfoList,
      );

      print(
        "StationRoutesBloc: About to emit Loaded state from single API call: ${newState.runtimeType}",
      );

      emit(newState);
      print("StationRoutesBloc: Emitted Loaded state from single API call.");
    } catch (e, stacktrace) {
      print(
        "StationRoutesBloc: Caught error during single API call for refresh: $e",
      );
      print("STACKTRACE: $stacktrace");
      emit(BusRouteMapError(
          message: e.toString(),
      ));
      print(
        "StationRoutesBloc: Emitted Error state from single API call error.",
      );
    }
  }

  // ********** 개선된 Polling 제어 메서드들 **********
  void pausePolling() {
    print("StationRoutesBloc: pausePolling called.");
    _isPollingPaused = true;
    print("StationRoutesBloc: Polling paused. API calls will be skipped.");
  }

  void resumePolling() {
    print("StationRoutesBloc: resumePolling called.");
    _isPollingPaused = false;
    print("StationRoutesBloc: Polling resumed. API calls will continue.");
  }

  void stopPolling() {
    print("StationRoutesBloc: stopPolling called.");
    _stopPollingSubject.add(null);
    _locationInfoSubscription?.cancel();
    _locationInfoSubscription = null;
    print("StationRoutesBloc: Polling completely stopped.");
  }

  // ********** Polling 상태 확인 **********
  bool get isPollingPaused => _isPollingPaused;

  bool get isPollingActive =>
      _locationInfoSubscription != null && !_isPollingPaused;
}
