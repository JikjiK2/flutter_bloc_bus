import 'package:equatable/equatable.dart';
import 'package:flutter_project/src/data/models/bus_location_info.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// 노선 정보 로딩 상태를 나타내는 enum

class BusRouteMapState extends Equatable {

  const BusRouteMapState();
  @override
  List<Object?> get props => [];
}

class BusRouteMapInitial extends BusRouteMapState { const BusRouteMapInitial(); }
class BusRouteMapLoading extends BusRouteMapState { const BusRouteMapLoading(); }

class BusRouteMapLoaded extends BusRouteMapState {
  final List<BusStopInfo> stops;
  final List<BusLocationInfo> locationInfoList;
  final Polyline? routePolyline; // 지도에 그릴 경로 Polyline 객체

  const BusRouteMapLoaded({
    required this.stops,
    required this.routePolyline,
    required this.locationInfoList,
  });

  @override
  List<Object> get props => [stops, locationInfoList]; // Equatable을 위해 stops 리스트 포함
}

class BusLocationLoaded extends BusRouteMapState {
  final List<BusLocationInfo> locationInfoList;

  const BusLocationLoaded({
    required this.locationInfoList,
  });

  @override
  List<Object> get props => [locationInfoList]; // Equatable을 위해 stops 리스트 포함
}

class BusRouteMapError extends BusRouteMapState {
  final String message;
  const BusRouteMapError({required this.message});
  @override
  List<Object> get props => [message];
}