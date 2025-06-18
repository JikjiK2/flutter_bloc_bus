// lib/src/blocs/nearby_stops_map/nearby_stops_map_state.dart
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // LatLng, Marker, Circle import

abstract class NearbyStopsMapState extends Equatable {
  const NearbyStopsMapState();
  @override
  List<Object> get props => [];
}

class NearbyStopsMapInitial extends NearbyStopsMapState { const NearbyStopsMapInitial(); }
class NearbyStopsMapLoading extends NearbyStopsMapState { const NearbyStopsMapLoading(); }

class NearbyStopsMapLoaded extends NearbyStopsMapState {
  final LatLng centerLocation; // 원의 중심 및 지도 이동 위치
  final Set<Marker> markers; // 지도에 표시할 마커들
  final Set<Circle> circles; // 지도에 표시할 원들

  const NearbyStopsMapLoaded({
    required this.centerLocation,
    required this.markers,
    required this.circles,
  });

  @override
  List<Object> get props => [centerLocation, markers, circles];
}

class NearbyStopsMapError extends NearbyStopsMapState {
  final String message;
  const NearbyStopsMapError({required this.message});
  @override
  List<Object> get props => [message];
}
