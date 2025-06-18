import 'package:json_annotation/json_annotation.dart';

part 'bus_location_response.g.dart';

@JsonSerializable()
class BusLocationResponse {
  final Response response;

  BusLocationResponse({required this.response});

  factory BusLocationResponse.fromJson(Map<String, dynamic> json) =>
      _$BusLocationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BusLocationResponseToJson(this);
}

@JsonSerializable()
class Response {
  final Header header;
  final Body body;

  Response({required this.header, required this.body});

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}

@JsonSerializable()
class Header {
  final String resultCode;
  final String resultMsg;

  Header({required this.resultCode, required this.resultMsg});

  factory Header.fromJson(Map<String, dynamic> json) => _$HeaderFromJson(json);

  Map<String, dynamic> toJson() => _$HeaderToJson(this);
}

@JsonSerializable()
class Body {
  final Items items;
  final int numOfRows;
  final int pageNo;
  final int totalCount;

  Body({required this.items, required this.numOfRows, required this.pageNo, required this.totalCount});

  factory Body.fromJson(Map<String, dynamic> json) => _$BodyFromJson(json);

  Map<String, dynamic> toJson() => _$BodyToJson(this);
}

@JsonSerializable()
class Items {
  final BusLocationItem item;

  Items({required this.item});

  factory Items.fromJson(Map<String, dynamic> json) => _$ItemsFromJson(json);

  Map<String, dynamic> toJson() => _$ItemsToJson(this);
}


@JsonSerializable()
class BusLocationItem {
  final double gpslati;
  final double gpslong;
  final String nodeid;
  final String nodenm;
  final int nodeord;
  final int routenm;
  final String routetp;
  final String vehicleno;

  BusLocationItem({
    required this.gpslati,
    required this.gpslong,
    required this.nodeid,
    required this.nodenm,
    required this.nodeord,
    required this.routenm,
    required this.routetp,
    required this.vehicleno,
  });

  factory BusLocationItem.fromJson(Map<String, dynamic> json) =>
      _$BusLocationItemFromJson(json);

  Map<String, dynamic> toJson() => _$BusLocationItemToJson(this);
}
