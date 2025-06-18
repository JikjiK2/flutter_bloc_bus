// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_search_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecentSearchItem _$RecentSearchItemFromJson(Map<String, dynamic> json) =>
    RecentSearchItem(
      searchType: $enumDecode(_$SearchTypeEnumMap, json['searchType']),
      cityCode: json['cityCode'] as String,
      itemId: json['itemId'] as String,
      itemName: json['itemName'],
      itemSubtitle: json['itemSubtitle'] as String,
      routetp: json['routetp'] as String,
      nodeno: json['nodeno'],
    );

Map<String, dynamic> _$RecentSearchItemToJson(RecentSearchItem instance) =>
    <String, dynamic>{
      'searchType': _$SearchTypeEnumMap[instance.searchType]!,
      'cityCode': instance.cityCode,
      'itemId': instance.itemId,
      'itemName': instance.itemName,
      'itemSubtitle': instance.itemSubtitle,
      'routetp': instance.routetp,
      'nodeno': instance.nodeno,
    };

const _$SearchTypeEnumMap = {
  SearchType.bus: 'bus',
  SearchType.station: 'station',
};
