import 'package:equatable/equatable.dart';

abstract class RouteStopsEvent extends Equatable {
  const RouteStopsEvent();
  @override
  List<Object> get props => [];
}

class LoadRouteStops extends RouteStopsEvent {
  final String cityCode;
  final String routeId;

  const LoadRouteStops({required this.cityCode, required this.routeId});

  @override
  List<Object> get props => [cityCode, routeId];
}
