import 'package:json_annotation/json_annotation.dart';

part 'bus_route_info.g.dart';

@JsonSerializable()
class BusRouteInfo {
  final String? routeid; // 노선 ID
  final dynamic routeno; // 노선 번호
  final String? routetp; // 노선 유형 (간선, 지선 등)
  final String? companyNm; // 운수 회사 이름
  final String? startnodenm;
  final String? endnodenm;
  final dynamic startvehicletime;
  final dynamic endvehicletime;
  final String? nodenm;
  final String? nodeid;
  final double? gpslati;
  final double? gpslong;
  final int? nodeord;


  BusRouteInfo({
    this.routeid,
    this.routeno,
    this.routetp,
    this.companyNm,
    this.startnodenm,
    this.endnodenm,
    this.startvehicletime,
    this.endvehicletime,
    this.nodenm,
    this.nodeid,
    this.gpslati,
    this.gpslong,
    this.nodeord,
  });

  factory BusRouteInfo.fromJson(Map<String, dynamic> json) =>
      _$BusRouteInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BusRouteInfoToJson(this);
}
