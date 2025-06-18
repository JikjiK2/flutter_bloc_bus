import 'package:equatable/equatable.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_state.dart';
import 'package:flutter_project/src/data/models/recent_search_item.dart'; // SearchType import


abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

// SharedPreferences에서 즐겨찾기 목록을 불러오는 이벤트
class LoadFavorites extends FavoriteEvent {}

// 특정 항목의 즐겨찾기 상태를 토글(추가 또는 삭제)하는 이벤트
class ToggleFavorite extends FavoriteEvent {
  final RecentSearchItem item; // 즐겨찾기 상태를 변경할 항목

  const ToggleFavorite(this.item);

  @override
  List<Object> get props => [item]; // Equatable 비교 기준 사용
}








/*abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}
class LoadFavorites extends FavoriteEvent {}
class InitialFavoriteLoaded extends FavoriteEvent {
  final List<RecentSearchItem> favorites;

  const InitialFavoriteLoaded({required this.favorites});

  @override
  List<Object> get props => [favorites];
}

class ToggleFavorites extends FavoriteEvent {
  final RecentSearchItem item;

  const ToggleFavorites({required this.item});

  @override
  List<Object> get props => [item];
}

class AddFavoriteItem extends FavoriteEvent {
  final RecentSearchItem item;

  const AddFavoriteItem({required this.item});

  @override
  List<Object> get props => [item];
}

class RemoveFavoriteItem extends FavoriteEvent {
  final RecentSearchItem item;

  const RemoveFavoriteItem({required this.item});

  @override
  List<Object> get props => [item];
}

class ClearFavoriteList extends FavoriteEvent {
  const ClearFavoriteList();

  @override
  List<Object> get props => [];
}*/
