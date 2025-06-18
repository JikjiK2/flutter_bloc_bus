// lib/src/blocs/nearby_stops_map/nearby_stops_map_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // LatLng, Marker, Circle import
import 'package:flutter_project/src/blocs/nearby_stops_map/nearby_stops_map_event.dart';
import 'package:flutter_project/src/blocs/nearby_stops_map/nearby_stops_map_state.dart';
import 'package:flutter_project/src/data/bus_repository.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart';
import 'package:flutter/material.dart'; // Colors import

class NearbyStopsMapBloc extends Bloc<NearbyStopsMapEvent, NearbyStopsMapState> {
  final BusRepository busRepository;
  static const double _searchRadius = 500.0; // 검색 반경 (미터)

  NearbyStopsMapBloc({required this.busRepository}) : super(NearbyStopsMapInitial()) {
    on<LoadNearbyStopsByCoordinates>(_onLoadNearbyStopsByCoordinates);
    on<LoadNearbyStopsByStop>(_onLoadNearbyStopsByStop);
  }

  Future<void> _onLoadNearbyStopsByCoordinates(
      LoadNearbyStopsByCoordinates event, Emitter<NearbyStopsMapState> emit) async {
    emit(NearbyStopsMapLoading());
    final center = LatLng(event.latitude, event.longitude);

    try {
      final nearbyStops = await busRepository.getNearbyStationsOnce(
        event.latitude.toString(),
        event.longitude.toString(),
      ).first;

      final Set<Marker> markers = {};
      // 중심 마커 추가
      markers.add(Marker(
        markerId: const MarkerId("center_location"),
        position: center,
        infoWindow: const InfoWindow(title: '중심 위치'),
      ));

      // 근처 정류소 마커 추가
      for (final stop in nearbyStops) {
        if (stop.latitude != null && stop.longitude != null) {
          markers.add(Marker(
            markerId: MarkerId(stop.nodeid ?? stop.nodenm ?? '${stop.latitude}_${stop.longitude}'),
            position: LatLng(stop.latitude!, stop.longitude!),
            infoWindow: InfoWindow(title: stop.nodenm ?? '정류소 이름 없음'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          ));
        }
      }

      // 반경 원 추가
      final Set<Circle> circles = {
        Circle(
          circleId: const CircleId("radius_circle"),
          center: center,
          radius: _searchRadius,
          strokeWidth: 2,
          fillColor: const Color(0x330000ff),
          strokeColor: Colors.blue,
          zIndex: 1,
        )
      };

      emit(NearbyStopsMapLoaded(centerLocation: center, markers: markers, circles: circles));

    } catch (e) {
      print('${e}');
      emit(NearbyStopsMapError(message: e.toString()));
    }
  }

  Future<void> _onLoadNearbyStopsByStop(
      LoadNearbyStopsByStop event, Emitter<NearbyStopsMapState> emit) async {
    emit(NearbyStopsMapLoading());

    try {
      final stopList  = await busRepository.getStationsByNumber(
        event.cityCode,
        event.nodeNm,
      ).first;

      if (stopList.isEmpty) {
        emit(NearbyStopsMapError(message: '선택한 정류소 정보를 찾을 수 없습니다.'));
        return;
      }
      final BusStopInfo stopDetails = stopList.first; // <--- 리스트에서 첫 번째 항목 꺼냄

      final center = LatLng(stopDetails.latitude!, stopDetails.longitude!);

      final nearbyStops = await busRepository.getNearbyStationsOnce(
        stopDetails.latitude!.toString(),
        stopDetails.longitude!.toString(),
      ).first;

      final Set<Marker> markers = {};
      // 중심 마커 (선택한 정류소) 추가
      markers.add(Marker(
        markerId: MarkerId(stopDetails.nodeid ?? stopDetails.nodenm ?? '${stopDetails.latitude}_${stopDetails.longitude}'),
        position: center,
        infoWindow: InfoWindow(title: stopDetails.nodenm ?? '정류소 이름 없음'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // 선택한 정류소는 다른 색상으로 표시
      ));

      // 근처 정류소 마커 추가 (중심 정류소 제외)
      for (final stop in nearbyStops) {
        if (stop.latitude != null && stop.longitude != null && stop.nodeid != stopDetails.nodeid) { // 중심 정류소 제외
          markers.add(Marker(
            markerId: MarkerId(stop.nodeid ?? stop.nodenm ?? '${stop.latitude}_${stop.longitude}'),
            position: LatLng(stop.latitude!, stop.longitude!),
            infoWindow: InfoWindow(title: stop.nodenm ?? '정류소 이름 없음'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          ));
        }
      }

      // 반경 원 추가
      final Set<Circle> circles = {
        Circle(
          circleId: const CircleId("radius_circle"),
          center: center,
          radius: _searchRadius,
          strokeWidth: 2,
          fillColor: const Color(0x330000ff),
          strokeColor: Colors.blue,
          zIndex: 1,
        )
      };

      emit(NearbyStopsMapLoaded(centerLocation: center, markers: markers, circles: circles));

    } catch (e) {
      emit(NearbyStopsMapError(message: e.toString()));
    }
  }
}
