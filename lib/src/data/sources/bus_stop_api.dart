import 'package:dio/dio.dart';
import 'package:flutter_project/src/data/api_client.dart';
import 'package:flutter_project/src/data/models/bus_stop_info.dart';
import 'package:flutter_project/src/data/query_param_builder.dart';

class BusStopApi {
  final String busApiServiceKey;
  final ApiClient apiClient;

  BusStopApi({required this.busApiServiceKey, required this.apiClient});

  Future<List<dynamic>> _fetchAllPages(
    String apiPath,
    Map<String, dynamic> initialParams,
    int pageSize, // 한 페이지에 요청할 결과 수
  ) async {
    List<dynamic> allItems = [];
    int currentPage = 1;
    int totalCount = 0;
    bool shouldContinue = true;

    print(
      "Repository: Starting fetchAllPages for $apiPath with pageSize $pageSize",
    );

    while (shouldContinue) {
      try {
        final queryBuilder = QueryParamBuilder(busApiServiceKey);
        queryBuilder.params.addAll(initialParams);
        queryBuilder.withParam('pageNo', currentPage.toString());
        queryBuilder.withParam('numOfRows', pageSize.toString());

        final queryParams = queryBuilder.build();

        print(
          "Repository: Fetching page $currentPage with params: $queryParams",
        );

        // API 호출 (ApiClient 사용)
        final data = await apiClient.fetchData(apiPath, queryParams);

        // 응답 데이터에서 totalCount와 item 목록 추출 및 유효성 검사
        if (data == null ||
            data['response'] == null ||
            data['response']['body'] == null) {
          print(
            "Repository: Unexpected API response structure for page $currentPage - Missing response or body",
          );
          shouldContinue = false; // 예상치 못한 구조 시 중단
          continue; // 다음 반복으로 이동
        }

        final responseBody = data['response']['body'];
        totalCount = responseBody['totalCount'] ?? 0; // totalCount 가져오기
        dynamic items = [];
        dynamic rawItems = responseBody['items']?['item'];

        print(
          "Repository: Page $currentPage fetched. Items: ${items.length}, TotalCount: $totalCount",
        );
        if (rawItems != null) {
          if (rawItems is List) {
            // 'item'이 이미 리스트 형태이면 그대로 사용
            items = rawItems;
            print("Repository: 'item' is a List. Items count: ${items.length}");
          } else if (rawItems is Map<String, dynamic>) {
            // 'item'이 단일 객체 형태이면 리스트로 감싸서 사용
            items = [rawItems];
            print("Repository: 'item' is a Map. Wrapped in a list.");
          } else {
            // 예상치 못한 타입인 경우
            print("Repository: Unexpected type for 'item' field: ${rawItems.runtimeType}");
            // items는 빈 리스트로 유지됩니다.
          }
        } else {
          print("Repository: 'item' field is null.");
        }
        // 현재 페이지의 아이템들을 전체 리스트에 추가
        allItems.addAll(items);

        // 다음 페이지가 있는지 확인: 현재까지 가져온 개수가 totalCount 보다 작으면 계속 진행
        if (allItems.length < totalCount) {
          currentPage++; // 다음 페이지로 이동
          // 무한 루프 방지: 만약 items가 비어있는데 totalCount가 더 크면 문제가 있는 것
          if (items.isEmpty && allItems.length < totalCount) {
            print(
              "Repository: Received empty items list for page $currentPage but totalCount indicates more data. Stopping to avoid infinite loop.",
            );
            shouldContinue = false;
          }
        } else {
          shouldContinue = false; // 모든 데이터를 가져왔거나 더 이상 데이터가 없으므로 반복 중단
        }
      } on DioException catch (e) {
        print("Repository: Error fetching page $currentPage for $apiPath: $e");
        // 에러 발생 시 반복 중단
        shouldContinue = false;
        // 에러를 다시 던져서 상위에서 처리하도록 할 수도 있습니다.
        // throw e;
      } catch (e) {
        print(
          "Repository: An unexpected error occurred fetching page $currentPage for $apiPath: $e",
        );
        shouldContinue = false;
        // throw e;
      }
    }

    print(
      "Repository: Finished fetching all pages for $apiPath. Total items collected: ${allItems.length}",
    );
    return allItems; // 모든 페이지에서 가져온 원시 결과 리스트 반환
  }

  // 좌표 기반 근접 정류소 목록 조회
  Future<List<BusStopInfo>> getStationsByLocation({
    required String gpsLati,
    required String gpsLong,
  }) async {
    final queryParams =
        QueryParamBuilder(
          busApiServiceKey,
        ).withParam('gpsLati', gpsLati).withParam('gpsLong', gpsLong).build();

    final data = await apiClient.fetchData(
      "/1613000/BusSttnInfoInqireService/getCrdntPrxmtSttnList",
      queryParams,
    );
    // data가 List<dynamic>인지 확인하고, 아니면 빈 리스트 반환
    List<dynamic> items =
        (data['response']['body']['items']['item'] as List<dynamic>?) ?? [];
    return items.map((item) => BusStopInfo.fromJson(item)).toList();
  }

  // 정류소 번호 목록 조회
  Future<List<BusStopInfo>> getStationsByNumber({
    required String cityCode,
    String? nodeNm,
    String? nodeNo,
  }) async {
    final queryParams =
        QueryParamBuilder(busApiServiceKey)
            .withParam('cityCode', cityCode)
            .withParam('nodeNm', nodeNm)
            .withParam('nodeNo', nodeNo)
            .build();

    final data = await apiClient.fetchData(
      "/1613000/BusSttnInfoInqireService/getSttnNoList",
      queryParams,
    );
    List<dynamic> items =
        (data['response']['body']['items']['item'] as List<dynamic>?) ?? [];
    return items.map((item) => BusStopInfo.fromJson(item)).toList();
  }

  // 정류소별 경유 노선 목록 조회
  Future<List<BusStopInfo>> getRouteByStation({
    required String cityCode,
    required String nodeId,
  }) async {
    final queryParams =
        QueryParamBuilder(
          busApiServiceKey,
        ).withParam('cityCode', cityCode).withParam('nodeId', nodeId).build();

    final data = await apiClient.fetchData(
      "/1613000/BusSttnInfoInqireService/getSttnThrghRouteList",
      queryParams,
    );
    List<dynamic> items =
        (data['response']['body']['items']['item'] as List<dynamic>?) ?? [];
    return items.map((item) => BusStopInfo.fromJson(item)).toList();
  }

  Future<List<BusStopInfo>> getAllRouteByStation({
    required String cityCode,
    String? nodeId,
    String? nodeNm,
    int pageSize = 1000,
  }) async {
    final rawItems = await _fetchAllPages(
      "/1613000/BusSttnInfoInqireService/getSttnThrghRouteList",
      {
        'cityCode': cityCode,
        'nodeid': nodeId,
        'nodenm': nodeNm,
      },
      pageSize,
    );
    if (rawItems.isNotEmpty) {
      print("--- First item structure and types ---");
      dynamic firstItem = rawItems.first;
      if (firstItem is Map<String, dynamic>) {
        firstItem.forEach((key, value) {
          print("  Field '$key': Value = $value, Type = ${value.runtimeType}"); // 필드 이름, 값, 타입 출력
        });
      } else {
        print("  First item is not a Map: ${firstItem.runtimeType}");
      }
      print("--------------------------------------");
    }
    return rawItems.map((item) => BusStopInfo.fromJson(item)).toList();
  }

  Future<List<BusStopInfo>> getAllStationsByNumber({
    required String cityCode,
    String? nodeNm,
    int pageSize = 1000,
  }) async {
    final rawItems = await _fetchAllPages(
      "/1613000/BusSttnInfoInqireService/getSttnNoList",
      {
        'cityCode': cityCode,
        'nodeNm': nodeNm,
      },
      pageSize,
    );
    if (rawItems.isNotEmpty) {
      print("--- First item structure and types ---");
      dynamic firstItem = rawItems.first;
      if (firstItem is Map<String, dynamic>) {
        firstItem.forEach((key, value) {
          print("  Field '$key': Value = $value, Type = ${value.runtimeType}"); // 필드 이름, 값, 타입 출력
        });
      } else {
        print("  First item is not a Map: ${firstItem.runtimeType}");
      }
      print("--------------------------------------");
    }
    return rawItems.map((item) => BusStopInfo.fromJson(item)).toList();
  }


}
