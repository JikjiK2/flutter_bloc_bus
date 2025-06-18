// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_stop_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusStopInfo _$BusStopInfoFromJson(Map<String, dynamic> json) => BusStopInfo(
  nodeid: json['nodeid'] as String?,
  nodenm: json['nodenm'] as String?,
  latitude: (json['gpslati'] as num?)?.toDouble(),
  longitude: (json['gpslong'] as num?)?.toDouble(),
  routeid: json['routeid'] as String?,
  routetp: json['routetp'] as String?,
  nodeno: json['nodeno'],
  routeno: json['routeno'],
);

Map<String, dynamic> _$BusStopInfoToJson(BusStopInfo instance) =>
    <String, dynamic>{
      'nodeid': instance.nodeid,
      'nodenm': instance.nodenm,
      'gpslati': instance.latitude,
      'gpslong': instance.longitude,
      'routeid': instance.routeid,
      'routetp': instance.routetp,
      'nodeno': instance.nodeno,
      'routeno': instance.routeno,
    };
