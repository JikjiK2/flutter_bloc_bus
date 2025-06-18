// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_location_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusLocationInfo _$BusLocationInfoFromJson(Map<String, dynamic> json) =>
    BusLocationInfo(
      vehicleno: json['vehicleno'],
      gpslati: json['gpslati'],
      gpslong: json['gpslong'],
      routeId: json['routeId'] as String?,
      remain_stop: (json['remain_stop'] as num?)?.toInt(),
      routenm: json['routenm'],
      nodeord: json['nodeord'],
      nodeid: json['nodeid'] as String?,
      nodenm: json['nodenm'] as String?,
    );

Map<String, dynamic> _$BusLocationInfoToJson(BusLocationInfo instance) =>
    <String, dynamic>{
      'vehicleno': instance.vehicleno,
      'gpslati': instance.gpslati,
      'gpslong': instance.gpslong,
      'routeId': instance.routeId,
      'remain_stop': instance.remain_stop,
      'routenm': instance.routenm,
      'nodeord': instance.nodeord,
      'nodeid': instance.nodeid,
      'nodenm': instance.nodenm,
    };
