import 'package:json_annotation/json_annotation.dart';

part 'bus_arrival_info.g.dart';

@JsonSerializable()
class BusArrivalInfo {
  final String? vehicletp;
  final String? routeid; // 노선 ID
  final String? nodeid; // 정류소 ID
  final String? nodenm;
  final String? routetp;
  final dynamic routeno;
  final int? arrprevstationcnt; // 남은 정류장 수
  final int? arrtime; // 남은 시간 (초)

  BusArrivalInfo({
    this.vehicletp,
    this.routeid,
    this.nodeid,
    this.arrprevstationcnt,
    this.arrtime,
    this.routetp,
    this.nodenm,
    this.routeno,
  });

  factory BusArrivalInfo.fromJson(Map<String, dynamic> json) =>
      _$BusArrivalInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BusArrivalInfoToJson(this);
}
