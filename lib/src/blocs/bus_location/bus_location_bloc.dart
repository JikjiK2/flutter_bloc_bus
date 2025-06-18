// lib/src/blocs/bus_location/bus_location_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/src/blocs/bus_location/bus_location_event.dart';
import 'package:flutter_project/src/blocs/bus_location/bus_location_item.dart';
import 'package:flutter_project/src/data/bus_location_response.dart';
import 'package:flutter_project/src/data/bus_repository.dart';
import 'package:rxdart/rxdart.dart';

class BusLocationBloc extends Bloc<BusLocationEvent, BusLocationState> {
  final BusRepository busRepository;

  BusLocationBloc({required this.busRepository}) : super(BusLocationInitial()) {
    // on<LoadBusLocations>(_onLoadBusLocations);
  }

  // debounce를 적용하여 잦은 API 호출을 방지
  EventTransformer<LoadBusLocations> debounce<LoadBusLocations>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  // Future<void> _onLoadBusLocations(
  //     LoadBusLocations event, Emitter<BusLocationState> emit) async {
  //   emit(BusLocationLoading()); // 로딩 상태 emit
  //
  //   try {
  //     // 버스 위치 정보를 가져오는 스트림 구독
  //     await emit.forEach<List<BusLocationItem>>(
  //       busRepository.getBusLocations(event.routeId),
  //       onData: (busLocations) => BusLocationLoaded(busLocations: busLocations), // 데이터 로드 완료 상태 emit
  //       onError: (error, stackTrace) {
  //         print('Error loading bus locations: $error');
  //         return BusLocationError(message: 'Failed to load bus locations'); // 에러 상태 emit
  //       },
  //     );
  //   } catch (e) {
  //     print('Error: $e');
  //     emit(BusLocationError(message: 'Failed to load bus locations')); // 예외 발생 시 에러 상태 emit
  //   }
  // }
}
