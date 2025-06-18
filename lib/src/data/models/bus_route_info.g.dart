// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_route_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusRouteInfo _$BusRouteInfoFromJson(Map<String, dynamic> json) => BusRouteInfo(
  routeid: json['routeid'] as String?,
  routeno: json['routeno'],
  routetp: json['routetp'] as String?,
  companyNm: json['companyNm'] as String?,
  startnodenm: json['startnodenm'] as String?,
  endnodenm: json['endnodenm'] as String?,
  startvehicletime: json['startvehicletime'],
  endvehicletime: json['endvehicletime'],
  nodenm: json['nodenm'] as String?,
  nodeid: json['nodeid'] as String?,
  gpslati: (json['gpslati'] as num?)?.toDouble(),
  gpslong: (json['gpslong'] as num?)?.toDouble(),
  nodeord: (json['nodeord'] as num?)?.toInt(),
);

Map<String, dynamic> _$BusRouteInfoToJson(BusRouteInfo instance) =>
    <String, dynamic>{
      'routeid': instance.routeid,
      'routeno': instance.routeno,
      'routetp': instance.routetp,
      'companyNm': instance.companyNm,
      'startnodenm': instance.startnodenm,
      'endnodenm': instance.endnodenm,
      'startvehicletime': instance.startvehicletime,
      'endvehicletime': instance.endvehicletime,
      'nodenm': instance.nodenm,
      'nodeid': instance.nodeid,
      'gpslati': instance.gpslati,
      'gpslong': instance.gpslong,
      'nodeord': instance.nodeord,
    };
