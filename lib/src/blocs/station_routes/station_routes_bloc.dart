import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/src/blocs/station_routes/station_routes_event.dart';
import 'package:flutter_project/src/blocs/station_routes/station_routes_state.dart';
import 'package:flutter_project/src/data/bus_repository.dart';
import 'package:flutter_project/src/data/models/bus_arrival_info.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart';
import 'package:rxdart/rxdart.dart';

class StationRoutesBloc extends Bloc<StationRoutesEvent, StationRoutesState> {
  final BusRepository busRepository;

  StreamSubscription? _arrivalInfoSubscription;

  String? _currentCityCode;
  String? _currentNodeId;
  List<BusStopInfo> _currentRoutesPassingStation = [];
  PublishSubject<void> _stopPollingSubject = PublishSubject<void>();
  final PublishSubject<void> _pausePollingSubject = PublishSubject<void>();
  final PublishSubject<void> _resumePollingSubject = PublishSubject<void>();

  bool _isPollingPaused = false;

  StationRoutesBloc({required this.busRepository})
      : super(StationRoutesInitial()) {
    on<LoadStationRoutes>(_onLoadStationRoutes);
    on<RefreshArrivalInfo>(_onRefreshArrivalInfo);
  }

  @override
  Future<void> close() async {
    _arrivalInfoSubscription?.cancel();
    _stopPollingSubject.close();
    _pausePollingSubject.close();
    _resumePollingSubject.close();
    print("StationRoutesBloc: close() called.");
    return super.close();
  }

  Future<void> _onLoadStationRoutes(
      LoadStationRoutes event,
      Emitter<StationRoutesState> emit,
      ) async {
    emit(
      StationRoutesLoading(
        stops: state.stops,
        arrivalInfoMap: state.arrivalInfoMap,
      ),
    );
    print("StationRoutesBloc: Emitted Loading state.");

    _currentCityCode = event.cityCode;
    _currentNodeId = event.nodeId;
    _isPollingPaused = false;

    // ********** 이전 스트림 구독 해제 **********
    await _arrivalInfoSubscription?.cancel();
    print("StationRoutesBloc: Previous subscription cancelled.");
    _stopPollingSubject.add(null);

    try {
      // 1. 특정 정류소를 지나는 노선 목록 가져오기 (BusStopInfo 형태로 표현)
      final List<BusStopInfo> routesPassingStation =
      await busRepository
          .getAllRouteByStation(event.cityCode, event.nodeId)
          .first;
      print(
        "StationRoutesBloc: Repository returned ${routesPassingStation.length} routes passing station.",
      );

      // 노선 목록 정렬 (routeno 기준 - dynamic 타입 처리)
      routesPassingStation.sort((a, b) {
        final dynamic routeNoA = a.routeno;
        final dynamic routeNoB = b.routeno;

        if (routeNoA == null && routeNoB == null) return 0;
        if (routeNoA == null) return 1;
        if (routeNoB == null) return -1;

        String routeNoStringA = '';
        if (routeNoA is int) {
          routeNoStringA = routeNoA.toString();
        } else if (routeNoA is String) {
          routeNoStringA = routeNoA;
        }

        String routeNoStringB = '';
        if (routeNoB is int) {
          routeNoStringB = routeNoB.toString();
        } else if (routeNoB is String) {
          routeNoStringB = routeNoB;
        }

        final RegExp numberPrefixRegExp = RegExp(r'^(\d+)(.*)');
        final matchA = numberPrefixRegExp.firstMatch(routeNoStringA);
        final matchB = numberPrefixRegExp.firstMatch(routeNoStringB);

        final bool startsWithNumberA = matchA != null;
        final bool startsWithNumberB = matchB != null;

        if (startsWithNumberA && !startsWithNumberB) return -1;
        if (!startsWithNumberA && startsWithNumberB) return 1;

        if (startsWithNumberA && startsWithNumberB) {
          final int numberA = int.tryParse(matchA!.group(1) ?? '0') ?? 0;
          final int numberB = int.tryParse(matchB!.group(1) ?? '0') ?? 0;

          if (numberA != numberB) {
            return numberA.compareTo(numberB);
          }

          final String remainingA = matchA.group(2) ?? '';
          final String remainingB = matchB.group(2) ?? '';

          final List<String> order = ['번', '-', '가곡'];

          int orderA = order.length;
          for (int i = 0; i < order.length; i++) {
            if (remainingA.startsWith(order[i])) {
              orderA = i;
              break;
            }
          }

          int orderB = order.length;
          for (int i = 0; i < order.length; i++) {
            if (remainingB.startsWith(order[i])) {
              orderB = i;
              break;
            }
          }

          if (orderA != orderB) {
            return orderA.compareTo(orderB);
          }

          return remainingA.compareTo(remainingB);
        } else {
          return routeNoStringA.compareTo(routeNoStringB);
        }
      });
      print("StationRoutesBloc: Sorted routesPassingStation by routeno.");

      _currentRoutesPassingStation = routesPassingStation; // 현재 노선 목록 저장
      final newState = StationRoutesLoaded(
        stops: _currentRoutesPassingStation, // 노선 목록 전달
        arrivalInfoMap: const {}, // 초기 도착 정보는 빈 맵
      );
      print("StationRoutesBloc: About to emit Loaded state with stops only: ${newState.runtimeType}");
      emit(newState); // <--- 노선 목록 로드 완료 상태 emit
      print("StationRoutesBloc: Emitted Loaded state with stops only.");



      // ********** 개선된 Polling Stream 생성 **********
      final Stream<List<BusArrivalInfo>> arrivalInfoPollingStream = _createControlledPollingStream(
        event.cityCode,
        event.nodeId,
      );

      print("StationRoutesBloc: Created controlled polling stream.");
      return emit.onEach<List<BusArrivalInfo>>( // <--- emit.onEach 사용
        arrivalInfoPollingStream, // 구독할 스트림
        onData: (arrivalInfoList) { // <--- 스트림이 내보내는 실제 데이터 (List<BusArrivalInfo>)
          print("StationRoutesBloc: Received ${arrivalInfoList.length} arrival info items from polling stream (via onEach).");

          final Map<String, BusArrivalInfo> arrivalInfoMap = {
            for (var arrival in arrivalInfoList)
              if (arrival.routeid != null) arrival.routeid!: arrival
          };
          print("StationRoutesBloc: Converted arrival info list to map. Map size: ${arrivalInfoMap.length}");

          // 로드 완료 상태 emit (onData/onError 콜백 내부에서 emit 호출)
          final newState = StationRoutesLoaded(
            stops: _currentRoutesPassingStation, // <--- 기존 노선 목록 사용
            arrivalInfoMap: arrivalInfoMap, // 새로 가져온 도착 정보 맵
          );
          print("StationRoutesBloc: About to emit Loaded state from polling stream data (via onEach): ${newState.runtimeType}");
          emit(newState); // <--- 상태 객체를 emit합니다.
          print("StationRoutesBloc: Emitted Loaded state from polling stream data.");

        },
        onError: (error, stacktrace) {
          print("StationRoutesBloc: Stream error during arrival info polling (via onEach): $error");
          print("STACKTRACE: $stacktrace");
          // 에러 상태 emit (onData/onError 콜백 내부에서 emit 호출)
          final errorState = StationRoutesError(message: error.toString(), stops: _currentRoutesPassingStation, arrivalInfoMap: state.arrivalInfoMap);
          print("StationRoutesBloc: About to emit Error state from stream error (via onEach): ${errorState.runtimeType}");
          emit(errorState); // <--- 에러 상태 객체를 emit합니다.
          print("StationRoutesBloc: Emitted Error state from stream error.");
        },
      );
    } catch (e, stacktrace) {
      print(
        "StationRoutesBloc: Caught error during initial data fetch or stream setup: $e",
      );
      print("STACKTRACE: $stacktrace");
      emit(
        StationRoutesError(
          message: e.toString(),
          stops: state.stops,
          arrivalInfoMap: state.arrivalInfoMap,
        ),
      );
      print("StationRoutesBloc: Emitted Error state from initial error.");
    }
  }

  // ********** 제어 가능한 Polling Stream 생성 **********
  Stream<List<BusArrivalInfo>> _createControlledPollingStream(
      String cityCode,
      String nodeId,
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
          .getArrivalInfoByStopAll(cityCode, nodeId)
          .handleError((error) {
        print("StationRoutesBloc: Error in polling API call: $error");
        throw error;
      });
    });
  }

  Future<void> _onRefreshArrivalInfo(
      RefreshArrivalInfo event,
      Emitter<StationRoutesState> emit,
      ) async {
    if (_currentCityCode == null || _currentNodeId == null) {
      print("StationRoutesBloc: Cannot refresh. CityCode or NodeId is null.");
      return;
    }

    emit(
      StationRoutesLoading(
        stops: state.stops,
        arrivalInfoMap: state.arrivalInfoMap,
      ),
    );
    print("StationRoutesBloc: Emitted Loading state for refresh.");

    try {
      final List<BusArrivalInfo> arrivalInfoList =
      await busRepository
          .getArrivalInfoByStopAll(_currentCityCode!, _currentNodeId!)
          .first;

      print(
        "StationRoutesBloc: Received ${arrivalInfoList.length} arrival info items from single API call for refresh.",
      );

      final newState = StationRoutesLoaded(
        stops: state.stops,
        arrivalInfoMap: {
          for (var arrival in arrivalInfoList)
            if (arrival.routeid != null) arrival.routeid!: arrival,
        },
      );

      print(
        "StationRoutesBloc: About to emit Loaded state from single API call: ${newState.runtimeType}",
      );

      emit(newState);
      print("StationRoutesBloc: Emitted Loaded state from single API call.");
    } catch (e, stacktrace) {
      print("StationRoutesBloc: Caught error during single API call for refresh: $e");
      print("STACKTRACE: $stacktrace");
      emit(StationRoutesError(
          message: e.toString(),
          stops: state.stops,
          arrivalInfoMap: state.arrivalInfoMap
      ));
      print("StationRoutesBloc: Emitted Error state from single API call error.");
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
    _arrivalInfoSubscription?.cancel();
    _arrivalInfoSubscription = null;
    print("StationRoutesBloc: Polling completely stopped.");
  }

  // ********** Polling 상태 확인 **********
  bool get isPollingPaused => _isPollingPaused;
  bool get isPollingActive => _arrivalInfoSubscription != null && !_isPollingPaused;
}