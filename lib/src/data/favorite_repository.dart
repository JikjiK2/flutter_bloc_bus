// lib/src/blocs/favorite/favorite_repository.dart (예시 경로)
import 'dart:convert'; // JSON 인코딩/디코딩을 위해 필요
import 'package:flutter_project/src/data/models/recent_search_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteRepository {
  final SharedPreferences prefs;
  // SharedPreferences에 즐겨찾기 목록이 저장될 고유한 키
  static const String _favoritesKey = 'user_favorite_items';

  FavoriteRepository({required this.prefs});

  // 즐겨찾기 목록 불러오기
  Future<List<RecentSearchItem>> loadFavorites() async {
    final List<String>? jsonStringList = prefs.getStringList(_favoritesKey);
    if (jsonStringList == null) {
      return []; // 저장된 데이터가 없으면 빈 리스트 반환
    }
    // JSON 문자열 리스트를 RecentSearchItem 객체 리스트로 변환
    return jsonStringList.map((jsonString) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return RecentSearchItem.fromJson(jsonMap);
    }).toList();
  }

  // 즐겨찾기 목록 저장하기
  Future<void> saveFavorites(List<RecentSearchItem> items) async {
    // RecentSearchItem 객체 리스트를 JSON 문자열 리스트로 변환
    final List<String> jsonStringList = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_favoritesKey, jsonStringList);
  }
}
