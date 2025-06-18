import 'package:equatable/equatable.dart';
import 'package:flutter_project/src/blocs/search/search_event.dart';

import 'package:flutter_project/src/data/models/bus_route_info.dart'; // 버스 노선 모델
import 'package:flutter_project/src/data/models/bus_stop_info.dart'; // 정류소 모델
import 'package:flutter_project/src/blocs/favorite/favorite_event.dart';
import 'package:flutter_project/src/data/models/recent_search_item.dart'; // SearchType import


enum FavoriteStatus { initial, loading, loaded, error }

class FavoriteState extends Equatable {
  final FavoriteStatus status; // 현재 상태
  final List<RecentSearchItem> favoriteItems; // 즐겨찾기된 RecentSearchItem 목록
  final String? errorMessage; // 에러 메시지

  const FavoriteState({
    this.status = FavoriteStatus.initial, // 초기 상태는 initial
    this.favoriteItems = const [], // 초기 목록은 비어있음
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, favoriteItems, errorMessage];

  // 상태 업데이트를 위한 copyWith 메서드
  FavoriteState copyWith({
    FavoriteStatus? status,
    List<RecentSearchItem>? favoriteItems,
    String? errorMessage,
  }) {
    return FavoriteState(
      status: status ?? this.status,
      favoriteItems: favoriteItems ?? this.favoriteItems,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}




// abstract class FavoriteState extends Equatable {
//
//   final List<RecentSearchItem> favorites;
//
//   const FavoriteState({required this.favorites});
//
//   @override
//   List<Object> get props => [favorites];
// }
//
// class FavoriteInitial extends FavoriteState {
//   const FavoriteInitial({required super.favorites});
// }
//
// // 로딩 상태
// class FavoriteLoading extends FavoriteState {
//   const FavoriteLoading({required super.favorites});
// }
//
// // 검색 결과 로드 완료 상태
// class FavoriteLoaded extends FavoriteState {
//   const FavoriteLoaded({
//     required super.favorites,
//   });
//
//   @override
//   List<Object> get props => [
//     favorites,
//   ];
// }
//
// // 에러 상태
// class FavoriteError extends FavoriteState {
//   final String message;
//
//   const FavoriteError({
//     required this.message, required super.favorites,
//   });
//   FavoriteError copyWith({
//     String? message,
//   }) {
//     return FavoriteError(
//       message: message ?? this.message,
//       favorites: favorites,
//     );
//   }
//   @override
//   List<Object> get props => [message];
// }
