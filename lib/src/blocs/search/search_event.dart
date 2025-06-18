import 'package:equatable/equatable.dart';
import 'package:flutter_project/src/blocs/search/search_state.dart';
import 'package:flutter_project/src/data/models/recent_search_item.dart'; // SearchType import

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class InitialRecentSearchesLoaded extends SearchEvent {
  final List<RecentSearchItem> recentSearches;

  const InitialRecentSearchesLoaded({required this.recentSearches});

  @override
  List<Object> get props => [recentSearches];
}

// 검색어 입력 이벤트
class SearchQueryChanged extends SearchEvent {
  final String query;
  final SearchType searchType; // 버스 검색인지 정류장 검색인지 구분
  final List<String> selectedCityCodes;

  const SearchQueryChanged({
    required this.query,
    required this.searchType,
    required this.selectedCityCodes, // <--- 필드 추가
  });

  @override
  List<Object> get props => [query, searchType, selectedCityCodes]; // <--- props에 포함
}

class AddRecentSearchItem extends SearchEvent {
  final RecentSearchItem item;

  const AddRecentSearchItem({required this.item});

  @override
  List<Object> get props => [item];
}

class RemoveRecentSearchItem extends SearchEvent {
  final RecentSearchItem item;

  const RemoveRecentSearchItem({required this.item});

  @override
  List<Object> get props => [item];
}

class ClearSearchQuery extends SearchEvent {
  const ClearSearchQuery();

  @override
  List<Object> get props => [];
}

enum SearchType { bus, station }
