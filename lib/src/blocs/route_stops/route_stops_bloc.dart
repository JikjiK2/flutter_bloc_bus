
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/src/blocs/route_stops/route_stops_event.dart';
import 'package:flutter_project/src/blocs/route_stops/route_stops_state.dart';
import 'package:flutter_project/src/data/bus_repository.dart';
// BusRepository import

class RouteStopsBloc extends Bloc<RouteStopsEvent, RouteStopsState> {
  final BusRepository busRepository;

  RouteStopsBloc({required this.busRepository}) : super(RouteStopsInitial()) {
    on<LoadRouteStops>(_onLoadRouteStops);
  }

  Future<void> _onLoadRouteStops(
      LoadRouteStops event, Emitter<RouteStopsState> emit) async {
    emit(RouteStopsLoading()); // 로딩 상태 시작
    try {
      final stops = await busRepository.getSelectedAllRouteStops(
          event.cityCode, event.routeId).first;
      emit(RouteStopsLoaded(stops: stops)); // 데이터 로드 완료 상태
    } catch (e) {
      emit(RouteStopsError(message: e.toString())); // 에러 상태
    }
  }
}
