import 'package:equatable/equatable.dart';
import 'package:flutter_project/src/blocs/search/search_event.dart';
import 'package:flutter_project/src/blocs/search/search_state.dart';
import 'package:json_annotation/json_annotation.dart'; // SearchType import

part 'recent_search_item.g.dart';

@JsonSerializable()
class RecentSearchItem extends Equatable {
  final SearchType searchType; // 버스 검색이었는지 정류장 검색이었는지
  final String cityCode; // 항목이 속한 도시 코드
  final String itemId; // 항목의 고유 ID (routeId 또는 nodeId)
  final dynamic itemName; // 항목의 이름 (routenm 또는 nodenm)
  final String? itemSubtitle; // 항목의 부가 정보 (유형, 회사, 번호 등)
  final String? routetp;
  final dynamic nodeno;

  const RecentSearchItem({
    required this.searchType,
    required this.cityCode,
    required this.itemId,
    required this.itemName,
    this.itemSubtitle,
    this.routetp,
    this.nodeno,
  });

  @override
  List<Object> get props => [searchType, cityCode, itemId, itemName]; // 중복 판단 기준 (쿼리, 타입, 도시, ID)

  factory RecentSearchItem.fromJson(Map<String, dynamic> json) =>
      _$RecentSearchItemFromJson(json);

  Map<String, dynamic> toJson() => _$RecentSearchItemToJson(this);
}
