import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/src/data/models/recent_search_item.dart';
import 'package:flutter_project/src/data/query_param_builder.dart';
import 'package:flutter_project/src/data/sources/bus_arrival_api.dart';
import 'package:flutter_project/src/data/api_client.dart'; // ApiClient import
import 'package:flutter_project/src/data/sources/bus_arrival_api.dart';
import 'package:flutter_project/src/data/sources/bus_stop_api.dart';
import 'package:flutter_project/src/data/sources/bus_route_api.dart';
import 'package:flutter_project/src/data/sources/bus_location_api.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart'; // BusStopInfo 모델 import
import 'package:flutter_project/src/data/models/bus_route_info.dart'; // BusRouteInfo 모델 import
import 'package:flutter_project/src/data/models/bus_location_info.dart'; // BusLocationInfo 모델 import
import 'package:flutter_project/src/data/models/bus_arrival_info.dart'; // BusArrivalInfo 모델 import
import 'package:rxdart/rxdart.dart'; // RxDart import
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class BusRepository {
  final BusArrivalApi busArrivalApi;
  final BusStopApi busStopApi;
  final BusRouteApi busRouteApi;
  final BusLocationApi busLocationApi;

  BusRepository({
    required this.busArrivalApi,
    required this.busStopApi,
    required this.busRouteApi,
    required this.busLocationApi,
  });

  Stream<List<BusStopInfo>> getNearbyStationsOnce(
    String gpsLati,
    String gpsLong,
  ) {
    // API를 한 번 호출하고 결과를 스트림으로 내보냅니다.
    return Rx.fromCallable(
      () =>
          busStopApi.getStationsByLocation(gpsLati: gpsLati, gpsLong: gpsLong),
    ).onErrorReturn([]); // 에러 발생 시 빈 리스트 반환하고 스트림 완료
  }

  Stream<List<BusStopInfo>> getStationsByNumber(
    String cityCode,
    String nodeNm,
  ) {
    // API를 한 번 호출하고 결과를 스트림으로 내보냅니다.
    return Rx.fromCallable(
      () => busStopApi.getStationsByNumber(cityCode: cityCode, nodeNm: nodeNm),
    ).onErrorReturn([]);
  }

  // 2. 노선 정보 항목 조회 (단발성 호출)
  Stream<List<BusRouteInfo>> getRouteInfoOnce(String cityCode, String routeId) {
    // API를 한 번 호출하고 결과를 스트림으로 내보냅니다.
    return Rx.fromCallable(
      () => busRouteApi.getRouteInfo(cityCode: cityCode, routeId: routeId),
    ).onErrorReturn([]); // 에러 발생 시 빈 리스트 반환하고 스트림 완료
  }



  // 4. 버스 도착 정보 조회 (실시간 필요한 경우 Polling 유지)
  // 이 메서드는 정류소별 도착 정보처럼 주기적 업데이트가 필요할 때 사용합니다.
  Stream<List<BusArrivalInfo>> getArrivalInfoPolling(
    String cityCode,
    String nodeId,
  ) {
    return Stream.periodic(const Duration(seconds: 30)) // Polling 간격
        .startWith(0) // 처음에도 즉시 데이터 가져오기
        .switchMap(
          (_) => Rx.fromCallable(
            () => busArrivalApi.getArrivalInfoByStop(
              cityCode: cityCode,
              nodeId: nodeId,
            ),
          ),
        )
        .onErrorReturn([]); // 에러 처리
  }

  // 예시: 특정 정류소 접근 버스 위치 정보 조회 (단발성 또는 필요에 따라 Polling)
  Stream<List<BusLocationInfo>> getBusLocationsByStopOnce(
    String cityCode,
    String routeId,
    String nodeId,
  ) {
    return Rx.fromCallable(
      () => busLocationApi.getBusLocationsByStop(
        cityCode: cityCode,
        routeId: routeId,
        nodeId: nodeId,
      ),
    ).onErrorReturn([]);
  }

  // 예시: 노선 번호 목록 조회 (단발성)
  Stream<List<BusRouteInfo>> getRouteListOnce(String cityCode, String routeNo) {
    return Rx.fromCallable(
      () => busRouteApi.getRouteList(cityCode: cityCode, routeNo: routeNo),
    ).onErrorReturn([]);
  }

  Stream<List<BusStopInfo>> getSelectedAllRouteStops(
    String cityCode,
    String routeId,
  ) {
    return Rx.fromCallable(
      () => busRouteApi.getAllBusLocationsOnce(
        cityCode: cityCode,
        routeId: routeId,
        pageSize: 1000,
      ),
    ).onErrorReturn([]);
  }

  Stream<List<BusRouteInfo>> getSelectedAllRouteList(
    String cityCode,
    String routeNo,
  ) {
    return Rx.fromCallable(
          () => busRouteApi.getSelectedAllRouteList(
            cityCode: cityCode,
            routeNo: routeNo,
            pageSize: 1000,
          ),
        )
        .doOnData((List<BusRouteInfo> stops) {
          // <--- 이 로그가 출력되는지 확인
          print(
            "Repository: getRouteStopsAll (Stream) emitted ${stops.length} stops.",
          ); // <--- 리스트 길이 확인
          if (stops.isNotEmpty) {
            print(
              "  First stop in list: ${stops.first.routeno}, ID: ${stops.first.routeid}",
            ); // 첫 항목 확인
          }
        })
        .doOnError((error, stacktrace) {
          print("getSelectedAllRouteList error: $error $stacktrace");
        })
        .onErrorReturn([]);
  }

  Stream<List<BusStopInfo>> getAllRouteByStation(
    String cityCode,
    String nodeId,
  ) {
    return Rx.fromCallable(
      () => busStopApi.getAllRouteByStation(
        cityCode: cityCode,
        nodeId: nodeId,
        pageSize: 1000,
      ),
    ).onErrorReturn([]);
  }

  Stream<List<BusStopInfo>> getAllStationsByNumber(
    String cityCode,
    String nodeNm,
  ) {
    return Rx.fromCallable(
      () => busStopApi.getAllStationsByNumber(
        cityCode: cityCode,
        nodeNm: nodeNm,
        pageSize: 1000,
      ),
    ).onErrorReturn([]);
  }

  Stream<List<BusArrivalInfo>> getArrivalInfoByStopAll(
    String cityCode,
    String nodeId,
  ) {
    return Rx.fromCallable(
      () => busArrivalApi.getArrivalInfoByStopAll(
        cityCode: cityCode,
        nodeId: nodeId,
        pageSize: 1000,
      ),
    ).onErrorReturn([]);
  }

  Stream<List<BusLocationInfo>> getBusLocationsAll(
      String cityCode,
      String nodeId,
      ) {
    return Rx.fromCallable(
          () => busLocationApi.getBusLocationByRouteAll(
        cityCode: cityCode,
        routeId: nodeId,
        pageSize: 1000,
      ),
    ).onErrorReturn([]);
  }

  Stream<List<BusLocationInfo>> getBusLocationsPolling({
    required String cityCode,
    required String routeId,
    Duration pollingInterval = const Duration(seconds: 10),
  }) {
    print(
      "Repository: Starting getBusLocationsPolling for station $routeId in city $cityCode with interval $pollingInterval",
    );
    return Stream.periodic(pollingInterval)
        .startWith(0)
        .switchMap((_) {
          print(
            "Repository: Polling trigger received. Fetching Location info for $routeId.",
          );
          return Stream.fromFuture(
            busLocationApi.getBusLocationByRouteAll(
              cityCode: cityCode,
              routeId: routeId,
              pageSize: 1000,
            ),
          );
        })
        .handleError((error, stacktrace) {
          print("Repository: Polling Stream Error for $routeId: $error");
          print("STACKTRACE: $stacktrace");
          return []; // 에러 발생 시 빈 리스트 반환하여 스트림 유지
        })
        .doOnData((data) {
          print(
            "Repository: Polling Stream emitted ${data.length} Location info items for $routeId.",
          ); // <--- 데이터 내보내는 로그
        });
  }

  Stream<List<BusArrivalInfo>> getArrivalInfoByStopPolling({
    required String cityCode,
    required String nodeId,
    Duration pollingInterval = const Duration(seconds: 10), // Polling 간격
  }) {
    print(
      "Repository: Starting getArrivalInfoByStopPolling for station $nodeId in city $cityCode with interval $pollingInterval",
    );
    return Stream.periodic(pollingInterval)
        .startWith(0)
        .switchMap((_) {
          // <--- 스트림에서 값이 내보내질 때마다 (초기 값 포함) 콜백 실행
          print(
            "Repository: Polling trigger received. Fetching arrival info for $nodeId.",
          );
          return Stream.fromFuture(
            busArrivalApi.getArrivalInfoByStopAll(
              cityCode: cityCode,
              nodeId: nodeId,
              pageSize: 1000,
            ),
          );
        })
        .handleError((error, stacktrace) {
          print("Repository: Polling Stream Error for $nodeId: $error");
          print("STACKTRACE: $stacktrace");
          return []; // 에러 발생 시 빈 리스트 반환하여 스트림 유지
        })
        .doOnData((data) {
          print(
            "Repository: Polling Stream emitted ${data.length} arrival info items for $nodeId.",
          ); // <--- 데이터 내보내는 로그
        });
  }

  static const String _recentSearchesKey = 'recent_searches';

  Future<List<RecentSearchItem>> loadRecentSearches() async {
    print("BusRepository: Loading recent searches from SharedPreferences.");
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? searchesString = prefs.getString(
        _recentSearchesKey,
      ); // 저장된 JSON 문자열 가져오기

      if (searchesString == null) {
        print("BusRepository: No recent searches found in SharedPreferences.");
        return []; // 저장된 데이터가 없으면 빈 리스트 반환
      }

      // JSON 문자열을 List<Map<String, dynamic>> 형태로 디코딩
      final List<dynamic> searchesJson = json.decode(searchesString);

      // 각 Map을 RecentSearchItem 객체로 변환
      final List<RecentSearchItem> recentSearches =
          searchesJson
              .map((itemJson) {
                try {
                  // RecentSearchItem.fromJson 메서드를 사용하여 변환
                  // RecentSearchItem 모델에 fromJson 팩토리 생성자 필요
                  return RecentSearchItem.fromJson(itemJson);
                } catch (e) {
                  print("BusRepository: Error decoding recent search item: $e");
                  return null; // 변환 오류 시 해당 항목 건너뛰기
                }
              })
              .whereType<RecentSearchItem>()
              .toList(); // null이 아닌 항목만 필터링

      print(
        "BusRepository: Successfully loaded ${recentSearches.length} recent searches.",
      );
      return recentSearches;
    } catch (e, stacktrace) {
      print("BusRepository: Error loading recent searches: $e");
      print("STACKTRACE: $stacktrace");
      return []; // 오류 발생 시 빈 리스트 반환
    }
  }

  // ********************************************

  // ********** 최근 검색 목록 저장하기 **********
  Future<void> saveRecentSearches(List<RecentSearchItem> recentSearches) async {
    print(
      "BusRepository: Saving ${recentSearches.length} recent searches to SharedPreferences.",
    );
    try {
      final prefs = await SharedPreferences.getInstance();

      // RecentSearchItem 리스트를 List<Map<String, dynamic>> 형태로 변환
      final List<Map<String, dynamic>> searchesJson =
          recentSearches.map((item) {
            // RecentSearchItem.toJson 메서드를 사용하여 변환
            // RecentSearchItem 모델에 toJson 메서드 필요
            return item.toJson();
          }).toList();

      // List<Map>을 JSON 문자열로 인코딩
      final String searchesString = json.encode(searchesJson);

      // SharedPreferences에 JSON 문자열 저장
      await prefs.setString(_recentSearchesKey, searchesString);
      print("BusRepository: Successfully saved recent searches.");
    } catch (e, stacktrace) {
      print("BusRepository: Error saving recent searches: $e");
      print("STACKTRACE: $stacktrace");
    }
  }

  static const String _favoritesKey = 'favorites';

  Future<List<RecentSearchItem>> loadFavorites() async {
    print("BusRepository: Loading favorites from SharedPreferences.");
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? searchesString = prefs.getString(
        _favoritesKey,
      ); // 저장된 JSON 문자열 가져오기

      if (searchesString == null) {
        print("BusRepository: No favorites found in SharedPreferences.");
        return []; // 저장된 데이터가 없으면 빈 리스트 반환
      }

      // JSON 문자열을 List<Map<String, dynamic>> 형태로 디코딩
      final List<dynamic> searchesJson = json.decode(searchesString);

      // 각 Map을 RecentSearchItem 객체로 변환
      final List<RecentSearchItem> recentSearches =
          searchesJson
              .map((itemJson) {
                try {
                  // RecentSearchItem.fromJson 메서드를 사용하여 변환
                  // RecentSearchItem 모델에 fromJson 팩토리 생성자 필요
                  return RecentSearchItem.fromJson(itemJson);
                } catch (e) {
                  print("BusRepository: Error decoding favorites item: $e");
                  return null; // 변환 오류 시 해당 항목 건너뛰기
                }
              })
              .whereType<RecentSearchItem>()
              .toList(); // null이 아닌 항목만 필터링

      print(
        "BusRepository: Successfully loaded ${recentSearches.length} favorites.",
      );
      return recentSearches;
    } catch (e, stacktrace) {
      print("BusRepository: Error loading favorites: $e");
      print("STACKTRACE: $stacktrace");
      return []; // 오류 발생 시 빈 리스트 반환
    }
  }

  Future<void> saveFavorites(List<RecentSearchItem> favorites) async {
    print(
      "BusRepository: Saving ${favorites.length} favorites to SharedPreferences.",
    );
    for (var item in favorites) {
      print(
        "BusRepository:${item.cityCode} ${item.itemId} ${item.itemName} favorites to SharedPreferences.",
      );
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // RecentSearchItem 리스트를 List<Map<String, dynamic>> 형태로 변환
      final List<Map<String, dynamic>> searchesJson =
          favorites.map((item) {
            // RecentSearchItem.toJson 메서드를 사용하여 변환
            // RecentSearchItem 모델에 toJson 메서드 필요
            return item.toJson();
          }).toList();

      // List<Map>을 JSON 문자열로 인코딩
      final String searchesString = json.encode(searchesJson);

      // SharedPreferences에 JSON 문자열 저장
      await prefs.setString(_favoritesKey, searchesString);
      print("BusRepository: Successfully saved favorites.");
    } catch (e, stacktrace) {
      print("BusRepository: Error saving favorites: $e");
      print("STACKTRACE: $stacktrace");
    }
  }
}
