// lib/src/blocs/nearby_stops_map/nearby_stops_map_event.dart
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // LatLng import

abstract class NearbyStopsMapEvent extends Equatable {
  const NearbyStopsMapEvent();
  @override
  List<Object> get props => [];
}

// 좌표 기준으로 근처 정류소 로드 이벤트
class LoadNearbyStopsByCoordinates extends NearbyStopsMapEvent {
  final double latitude;
  final double longitude;

  const LoadNearbyStopsByCoordinates({required this.latitude, required this.longitude});

  @override
  List<Object> get props => [latitude, longitude];
}

// 특정 정류소 기준으로 근처 정류소 로드 이벤트
class LoadNearbyStopsByStop extends NearbyStopsMapEvent {
  final String cityCode;
  final String nodeNm;

  const LoadNearbyStopsByStop({required this.cityCode, required this.nodeNm});

  @override
  List<Object> get props => [cityCode, nodeNm];
}
