import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/src/blocs/city/city_state.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_event.dart';
import 'package:flutter_project/src/blocs/favorite/favorite_state.dart';
import 'package:flutter_project/src/data/models/recent_search_item.dart';
import 'package:flutter_project/src/data/bus_repository.dart';
import 'package:flutter_project/src/blocs/city/city_bloc.dart';
import 'package:flutter_project/src/data/favorite_repository.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository _repository;

  FavoriteBloc({required FavoriteRepository repository})
      : _repository = repository,
        super(const FavoriteState()) {
    // 초기 상태 설정
    // 이벤트 핸들러 등록
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorites);
  }

  Future<void> _onLoadFavorites(LoadFavorites event,
      Emitter<FavoriteState> emit,) async {
    emit(state.copyWith(status: FavoriteStatus.loading)); // 로딩 상태 시작
    try {
      final items = await _repository.loadFavorites();
      // 로드 완료 상태와 함께 불러온 목록을 발행
      emit(state.copyWith(
        status: FavoriteStatus.loaded,
        favoriteItems: items,
        errorMessage: null, // 성공 시 에러 메시지 초기화
      ));
      print('Loaded ${items.length} favorite items.'); // 로딩 확인 로그
    } catch (e) {
      // 에러 발생 시 에러 상태 발행
      emit(state.copyWith(
        status: FavoriteStatus.error,
        favoriteItems: [], // 에러 발생 시 목록 초기화 또는 기존 목록 유지 선택
        errorMessage: '즐겨찾기 목록을 불러오는데 실패했습니다: ${e.toString()}',
      ));
      print('Error loading favorites: $e'); // 에러 로그
    }
  }

  // ToggleFavorite 이벤트 처리: 특정 항목의 즐겨찾기 상태를 토글합니다.
  Future<void> _onToggleFavorites(ToggleFavorite event,
      Emitter<FavoriteState> emit,) async {
    final itemToToggle = event.item;
    // 현재 상태의 즐겨찾기 목록을 가져와서 수정 가능한 리스트로 복사합니다.
    List<RecentSearchItem> currentFavorites = List.from(state.favoriteItems);

    // 이미 즐겨찾기된 항목인지 확인합니다. (RecentSearchItem의 Equatable props 기준)
    if (currentFavorites.contains(itemToToggle)) {
      // 이미 있으면 제거
      currentFavorites.remove(itemToToggle);
      print('Removed from favorites: ${itemToToggle.itemName}'); // 로그
    } else {
      // 없으면 추가
      currentFavorites.add(itemToToggle);
      print('Added to favorites: ${itemToToggle.itemName}'); // 로그
    }

    try {
      // 변경된 목록을 SharedPreferences에 저장합니다.
      await _repository.saveFavorites(currentFavorites);
      // 업데이트된 목록으로 새로운 상태를 발행(emit)하여 UI를 업데이트합니다.
      emit(state.copyWith(favoriteItems: currentFavorites));
      print('Favorites saved.'); // 저장 확인 로그
    } catch (e) {
      print('Error saving favorites: $e'); // 에러 로그
      // 저장 중 에러 발생 시 에러 상태 발행 (기존 목록은 유지)
      // emit(state.copyWith(status: FavoriteStatus.error, errorMessage: '즐겨찾기 저장/삭제 실패: ${e.toString()}'));
    }
  }
}











//
//   Future<void> _onLoadFavorites(
//     LoadFavorites event,
//     Emitter<FavoriteState> emit,
//   ) async {
//     final cityState = cityBloc.state;
//     final List<String> selectedCityCodes = cityState.selectedCityCodes;
//
//     if (selectedCityCodes.isEmpty) {
//       emit(FavoriteInitial(favorites: state.favorites));
//       return;
//     }
//     if (selectedCityCodes.isNotEmpty) {
//       emit(
//         FavoriteLoading(favorites: state.favorites
//         ),
//       );
//     }
//     try{
//       final newState = await busRepository.loadFavorites();
//       emit(FavoriteLoaded(favorites: newState));
//     } catch (e){
//       print("FavoriteBloc: Error loading initial recent searches: $e");
//       emit(FavoriteError(message: e.toString(), favorites: state.favorites));
//     }
//   }
//
//   Future<void> _onToggleFavorites(
//     ToggleFavorites event,
//     Emitter<FavoriteState> emit,
//   ) async {
//     final List<RecentSearchItem> favorites = List.from(
//       state.favorites,
//     ); // 기존 리스트 복사
//
//     // 추가하려는 항목과 동일한 항목이 이미 리스트에 있는지 확인
//     final int existingIndex = favorites.indexWhere(
//       (item) =>
//           item.searchType == event.item.searchType &&
//           item.cityCode == event.item.cityCode &&
//           item.itemId == event.item.itemId,
//     );
//
//     if (existingIndex != -1) {
//       // 동일한 항목이 있으면 기존 항목 제거
//       favorites.removeAt(existingIndex);
//       print("FavoriteBloc: Removed existing duplicate favorites item.");
//     } else {
//       favorites.add(event.item);
//       print(
//         "FavoriteBloc: Added new favorites item to the front. Total items: ${favorites.length}",
//       );
//     }
//
//     try {
//       // 변경된 목록을 SharedPreferences에 저장
//       await busRepository.saveFavorites(favorites);
//       // 상태 업데이트 (favoriteRoutes는 그대로 유지)
//       emit(FavoriteLoaded(favorites: favorites));
//     } catch (e) {
//       // 저장 중 에러 발생 시 에러 상태 발행 (기존 목록은 유지)
//       emit(
//         FavoriteError(
//           message: e.toString(),
//           favorites: favorites,
//         ),
//       );
//     }
//   }
//
//   Future<void> _onClearFavoriteList(
//     ClearFavoriteList event,
//     Emitter<FavoriteState> emit,
//   ) async {
//     return emit(FavoriteInitial(favorites: []));
//   }
// }
