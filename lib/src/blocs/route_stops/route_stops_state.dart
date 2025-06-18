import 'package:equatable/equatable.dart';
import 'package:flutter_project/src/data/models/bus_route_info.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart';


abstract class RouteStopsState extends Equatable {
  const RouteStopsState();
  @override
  List<Object> get props => [];
}

class RouteStopsInitial extends RouteStopsState { const RouteStopsInitial(); }
class RouteStopsLoading extends RouteStopsState { const RouteStopsLoading(); }

class RouteStopsLoaded extends RouteStopsState {
  final List<BusStopInfo> stops;
  const RouteStopsLoaded({required this.stops});

  @override
  List<Object> get props => [stops]; // Equatable을 위해 stops 리스트 포함
}

class RouteStopsError extends RouteStopsState {
  final String message;
  const RouteStopsError({required this.message});
  @override
  List<Object> get props => [message];
}
