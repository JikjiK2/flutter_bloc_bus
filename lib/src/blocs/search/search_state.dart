// lib/src/blocs/search/search_state.dart
import 'package:equatable/equatable.dart';

// 모델 import 경로를 프로젝트 구조에 맞게 수정하세요.
import 'package:flutter_project/src/data/models/bus_route_info.dart'; // 버스 노선 모델
import 'package:flutter_project/src/data/models/bus_stop_info.dart'; // 정류소 모델
import 'package:flutter_project/src/blocs/search/search_event.dart';
import 'package:flutter_project/src/data/models/recent_search_item.dart'; // SearchType import

abstract class SearchState extends Equatable {
  final String currentQuery;
  final SearchType currentSearchType;
  final List<String> selectedCityCodes;
  final List<RecentSearchItem> recentSearches;

  const SearchState({
    this.currentQuery = '',
    this.currentSearchType = SearchType.bus,
    this.selectedCityCodes = const [],
    this.recentSearches = const [],
  });

  SearchState copyWith({
    String? currentQuery,
    SearchType? currentSearchType,
    List<String>? selectedCityCodes,
    List<RecentSearchItem>? recentSearches, // 필드 추가
    Map<String, List<BusRouteInfo>>? busResults, // SearchLoaded 상태용
    Map<String, List<BusStopInfo>>? stationResults, // SearchLoaded 상태용
    String? message, // SearchError 상태용
  });

  @override
  List<Object> get props => [
    currentQuery,
    currentSearchType,
    selectedCityCodes,
  ];
}

// 초기 상태 (검색 전)
class SearchInitial extends SearchState {
  const SearchInitial({
    super.currentQuery,
    super.currentSearchType,
    super.selectedCityCodes,
    super.recentSearches,
  });

  SearchInitial copyWith({
    String? currentQuery,
    SearchType? currentSearchType,
    List<String>? selectedCityCodes,
    List<RecentSearchItem>? recentSearches, // 필드 추가
    Map<String, List<BusRouteInfo>>? busResults, // 사용 안 함
    Map<String, List<BusStopInfo>>? stationResults, // 사용 안 함
    String? message, // 사용 안 함
  }) {
    return SearchInitial(
      currentQuery: currentQuery ?? this.currentQuery,
      currentSearchType: currentSearchType ?? this.currentSearchType,
      selectedCityCodes: selectedCityCodes ?? this.selectedCityCodes,
      recentSearches: recentSearches ?? this.recentSearches, // 필드 업데이트
    );
  }
}

// 로딩 상태
class SearchLoading extends SearchState {
  const SearchLoading({
    required super.currentQuery,
    required super.currentSearchType,
    required super.selectedCityCodes,
    required super.recentSearches,
  });

  SearchLoading copyWith({
    String? currentQuery,
    SearchType? currentSearchType,
    List<String>? selectedCityCodes,
    List<RecentSearchItem>? recentSearches, // 필드 추가
    Map<String, List<BusRouteInfo>>? busResults, // 사용 안 함
    Map<String, List<BusStopInfo>>? stationResults, // 사용 안 함
    String? message, // 사용 안 함
  }) {
    return SearchLoading(
      currentQuery: currentQuery ?? this.currentQuery,
      currentSearchType: currentSearchType ?? this.currentSearchType,
      selectedCityCodes: selectedCityCodes ?? this.selectedCityCodes,
      recentSearches: recentSearches ?? this.recentSearches, // 필드 업데이트
    );
  }
}

// 검색 결과 로드 완료 상태
class SearchLoaded extends SearchState {
  final Map<String, List<BusRouteInfo>>
  busResults; // Map<cityCode, List<BusRouteInfo>>
  final Map<String, List<BusStopInfo>>
  stationResults; // Map<cityCode, List<BusStopInfo>>

  const SearchLoaded({
    required this.busResults,
    required this.stationResults,
    required super.currentQuery,
    required super.currentSearchType,
    required super.selectedCityCodes,
    super.recentSearches = const [],
  });

  @override
  SearchLoaded copyWith({
    String? currentQuery,
    SearchType? currentSearchType,
    List<String>? selectedCityCodes,
    List<RecentSearchItem>? recentSearches, // 필드 추가
    Map<String, List<BusRouteInfo>>? busResults,
    Map<String, List<BusStopInfo>>? stationResults,
    String? message, // 사용 안 함
  }) {
    return SearchLoaded(
      busResults: busResults ?? this.busResults,
      stationResults: stationResults ?? this.stationResults,
      currentQuery: currentQuery ?? this.currentQuery,
      currentSearchType: currentSearchType ?? this.currentSearchType,
      selectedCityCodes: selectedCityCodes ?? this.selectedCityCodes,
      recentSearches: recentSearches ?? this.recentSearches, // 필드 업데이트
    );
  }

  @override
  List<Object> get props => [
    busResults,
    stationResults,
    currentQuery,
    currentSearchType,
    selectedCityCodes,
    recentSearches,
  ];
}

// 에러 상태
class SearchError extends SearchState {
  final String message;

  const SearchError({
    required this.message,
    required super.currentQuery,
    required super.currentSearchType,
    required super.selectedCityCodes,
    super.recentSearches = const [],
  });

  SearchError copyWith({
    String? currentQuery,
    SearchType? currentSearchType,
    List<String>? selectedCityCodes,
    List<RecentSearchItem>? recentSearches, // 필드 추가
    Map<String, List<BusRouteInfo>>? busResults, // 사용 안 함
    Map<String, List<BusStopInfo>>? stationResults, // 사용 안 함
    String? message,
  }) {
    return SearchError(
      message: message ?? this.message,
      currentQuery: currentQuery ?? this.currentQuery,
      currentSearchType: currentSearchType ?? this.currentSearchType,
      selectedCityCodes: selectedCityCodes ?? this.selectedCityCodes,
      recentSearches: recentSearches ?? this.recentSearches, // 필드 업데이트
    );
  }

  @override
  List<Object> get props => [
    message,
    currentQuery,
    currentSearchType,
    selectedCityCodes,
    recentSearches,
  ];
}
