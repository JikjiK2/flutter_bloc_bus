import 'package:equatable/equatable.dart';

abstract class BusRouteMapEvent extends Equatable {
  const BusRouteMapEvent();
  @override
  List<Object> get props => [];
}

// 특정 노선 ID에 대한 정보를 불러오는 이벤트
class LoadBusRoute extends BusRouteMapEvent {
  final String cityCode;
  final String routeId; // 불러올 노선의 ID

  const LoadBusRoute({required this.cityCode, required this.routeId});

  @override
  List<Object> get props => [cityCode, routeId];
}

class RefreshLocationInfo extends BusRouteMapEvent {
  const RefreshLocationInfo();
}