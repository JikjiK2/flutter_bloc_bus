import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bus_stop_info.g.dart';

@JsonSerializable()
class BusStopInfo {
  final String? nodeid;
  final String? nodenm;
  @JsonKey(name: 'gpslati')
  final double? latitude;
  @JsonKey(name: 'gpslong')
  final double? longitude;
  final String? routeid;
  final String? routetp;
  final dynamic nodeno;
  final dynamic routeno;

  LatLng toLatLng() {
    return LatLng(latitude!, longitude!);
  }

  BusStopInfo({
    this.nodeid,
    this.nodenm,
    this.latitude,
    this.longitude,
    this.routeid,
    this.routetp,
    this.nodeno,
    this.routeno,
  });

  factory BusStopInfo.fromJson(Map<String, dynamic> json) =>
      _$BusStopInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BusStopInfoToJson(this);
}
