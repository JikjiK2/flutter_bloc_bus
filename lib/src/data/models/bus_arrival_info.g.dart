// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_arrival_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusArrivalInfo _$BusArrivalInfoFromJson(Map<String, dynamic> json) =>
    BusArrivalInfo(
      vehicletp: json['vehicletp'] as String?,
      routeid: json['routeid'] as String?,
      nodeid: json['nodeid'] as String?,
      arrprevstationcnt: (json['arrprevstationcnt'] as num?)?.toInt(),
      arrtime: (json['arrtime'] as num?)?.toInt(),
      routetp: json['routetp'] as String?,
      nodenm: json['nodenm'] as String?,
      routeno: json['routeno'],
    );

Map<String, dynamic> _$BusArrivalInfoToJson(BusArrivalInfo instance) =>
    <String, dynamic>{
      'vehicletp': instance.vehicletp,
      'routeid': instance.routeid,
      'nodeid': instance.nodeid,
      'nodenm': instance.nodenm,
      'routetp': instance.routetp,
      'routeno': instance.routeno,
      'arrprevstationcnt': instance.arrprevstationcnt,
      'arrtime': instance.arrtime,
    };
