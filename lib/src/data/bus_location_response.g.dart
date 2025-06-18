// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_location_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusLocationResponse _$BusLocationResponseFromJson(Map<String, dynamic> json) =>
    BusLocationResponse(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BusLocationResponseToJson(
  BusLocationResponse instance,
) => <String, dynamic>{'response': instance.response};

Response _$ResponseFromJson(Map<String, dynamic> json) => Response(
  header: Header.fromJson(json['header'] as Map<String, dynamic>),
  body: Body.fromJson(json['body'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
  'header': instance.header,
  'body': instance.body,
};

Header _$HeaderFromJson(Map<String, dynamic> json) => Header(
  resultCode: json['resultCode'] as String,
  resultMsg: json['resultMsg'] as String,
);

Map<String, dynamic> _$HeaderToJson(Header instance) => <String, dynamic>{
  'resultCode': instance.resultCode,
  'resultMsg': instance.resultMsg,
};

Body _$BodyFromJson(Map<String, dynamic> json) => Body(
  items: Items.fromJson(json['items'] as Map<String, dynamic>),
  numOfRows: (json['numOfRows'] as num).toInt(),
  pageNo: (json['pageNo'] as num).toInt(),
  totalCount: (json['totalCount'] as num).toInt(),
);

Map<String, dynamic> _$BodyToJson(Body instance) => <String, dynamic>{
  'items': instance.items,
  'numOfRows': instance.numOfRows,
  'pageNo': instance.pageNo,
  'totalCount': instance.totalCount,
};

Items _$ItemsFromJson(Map<String, dynamic> json) =>
    Items(item: BusLocationItem.fromJson(json['item'] as Map<String, dynamic>));

Map<String, dynamic> _$ItemsToJson(Items instance) => <String, dynamic>{
  'item': instance.item,
};

BusLocationItem _$BusLocationItemFromJson(Map<String, dynamic> json) =>
    BusLocationItem(
      gpslati: (json['gpslati'] as num).toDouble(),
      gpslong: (json['gpslong'] as num).toDouble(),
      nodeid: json['nodeid'] as String,
      nodenm: json['nodenm'] as String,
      nodeord: (json['nodeord'] as num).toInt(),
      routenm: (json['routenm'] as num).toInt(),
      routetp: json['routetp'] as String,
      vehicleno: json['vehicleno'] as String,
    );

Map<String, dynamic> _$BusLocationItemToJson(BusLocationItem instance) =>
    <String, dynamic>{
      'gpslati': instance.gpslati,
      'gpslong': instance.gpslong,
      'nodeid': instance.nodeid,
      'nodenm': instance.nodenm,
      'nodeord': instance.nodeord,
      'routenm': instance.routenm,
      'routetp': instance.routetp,
      'vehicleno': instance.vehicleno,
    };
