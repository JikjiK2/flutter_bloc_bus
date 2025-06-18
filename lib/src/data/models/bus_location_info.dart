import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bus_location_info.g.dart';

@JsonSerializable()
class BusLocationInfo {
  final dynamic vehicleno; // 차량 번호
  final dynamic gpslati; // 위도
  final dynamic gpslong; // 경도
  final String? routeId; // 노선 ID
  final int? remain_stop; // 남은 정류장 수
  final dynamic routenm;
  final dynamic nodeord;
  final String? nodeid;
  final String? nodenm;

  BusLocationInfo({
    this.vehicleno,
    this.gpslati,
    this.gpslong,
    this.routeId,
    this.remain_stop,
    this.routenm,
    this.nodeord,
    this.nodeid,
    this.nodenm,
  });

  LatLng toLatLng() {
    double lati = 0.0;
    double long = 0.0;
    if(gpslati != null && gpslong != null){
      if(gpslati is String) {
        lati = double.parse(gpslati);
      }
      if(gpslong is String) {
        long = double.parse(gpslong);
      }
      if(gpslong is double) long = gpslong;
      if(gpslati is double) lati = gpslati;
      return LatLng(lati, long);
    }
    return LatLng(0, 0);

  }

  factory BusLocationInfo.fromJson(Map<String, dynamic> json) =>
      _$BusLocationInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BusLocationInfoToJson(this);
}
