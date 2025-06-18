import 'package:dio/dio.dart';
import 'package:flutter_project/src/data/api_client.dart';
import 'package:flutter_project/src/data/models/bus_arrival_info.dart';
import 'package:flutter_project/src/data/query_param_builder.dart';

class BusArrivalApi {
  final String busApiServiceKey;
  final ApiClient apiClient;

  BusArrivalApi({required this.busApiServiceKey, required this.apiClient});

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
        dynamic rawItemsContainer = responseBody['items'];
        print(
          "Repository: Page $currentPage fetched. Items: ${items.length}, TotalCount: $totalCount",
        );

        if (rawItemsContainer != null && rawItemsContainer is Map<String, dynamic>) {
          if(rawItems != null){
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
          }

        } else if (rawItemsContainer != null && rawItemsContainer is String && rawItemsContainer.isEmpty) {
          print("Repository: 'items' container is an empty String. Treating as empty list.");
          items = []; // 빈 리스트로 처리
        }
        else {
          print("Repository: 'item' field is null.");
        }

        // 현재 페이지의 아이템들을 전체 리스트에 추가
        try {
          // 원시 아이템들을 BusStopInfo 모델로 변환하여 전체 리스트에 추가
          // 이 map 과정에서 BusStopInfo.fromJson 호출 시 오류 발생 가능성 높음
          allItems.addAll(items); // <--- 이 라인에서 오류 발생 가능성
          print("BusRouteApi: Successfully mapped ${items.length} items to BusStopInfo for page $currentPage.");

        } catch (e, stacktrace) {
          // 모델 변환 중 오류 발생 시
          print("BusRouteApi: ERROR during model mapping for page $currentPage: $e"); // <--- 오류 메시지 출력
          print("STACKTRACE: $stacktrace");
          shouldContinue = false;
          continue;
        }

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
        throw e;
      } catch (e) {
        print(
          "Repository: An unexpected error occurred fetching page $currentPage for $apiPath: $e",
        );
        shouldContinue = false;
      }
    }

    print(
      "Repository: Finished fetching all pages for $apiPath. Total items collected: ${allItems.length}",
    );
    return allItems; // 모든 페이지에서 가져온 원시 결과 리스트 반환
  }

  Future<List<BusArrivalInfo>> getArrivalInfoByStopAll({ // 메서드 이름과 반환 타입 확인
    required String cityCode,
    required String nodeId,
    int pageSize = 1000, // API가 허용하는 최대값 (문서 확인 필수!)
  }) async {
    print("Repository: Calling getArrivalInfoByStopAll for station $nodeId in city $cityCode");
    // _fetchAllPages를 사용하여 모든 페이지의 원시 데이터 가져오기
    try {
      final rawItems = await _fetchAllPages(
        "/1613000/ArvlInfoInqireService/getSttnAcctoArvlPrearngeInfoList", // 실제 API path
        {
          'cityCode': cityCode,
          'nodeId': nodeId,
        },
        pageSize,
      );
      print("BusArrivalApi: Received ${rawItems.length} raw items from _fetchAllPages.");

      // 원시 아이템들을 BusArrivalInfo 모델로 변환하는 부분
      print("BusArrivalApi: Starting mapping raw items to BusArrivalInfo.");
      final List<BusArrivalInfo> arrivalInfoList = rawItems.map((item) {
        // 각 item은 Map<String, dynamic> 형태의 원시 JSON 항목입니다.
        // 이 item을 BusArrivalInfo.fromJson으로 변환합니다.
        // 오류 발생 시 디버깅을 위한 try-catch 추가
        try {
          final arrivalInfo = BusArrivalInfo.fromJson(item); // <--- 이 라인에서 오류 발생 가능성
          return arrivalInfo;
        } catch (e, stacktrace) {
          print("BusArrivalApi: ERROR mapping item to BusArrivalInfo: $e"); // <--- 오류 메시지 출력
          print("STACKTRACE: $stacktrace"); // <--- 스택 트레이스 출력
          return null; // 오류 발생 시 null 반환
        }
      }).whereType<BusArrivalInfo>().toList(); // null이 아닌 BusArrivalInfo 객체만 필터링하여 리스트 생성
      print("BusArrivalApi: Successfully mapped ${arrivalInfoList.length} items to BusArrivalInfo.");

      return arrivalInfoList; // <--- List<BusArrivalInfo> 반환
    } on DioException catch (e) {
      print("BusArrivalApi: Error fetching arrival info: $e");
      throw e; // Repository에서 잡을 수 있도록 에러 다시 던지기
    } catch (e, stacktrace) {
      print("BusArrivalApi: An unexpected error occurred fetching arrival info: $e");
      print("STACKTRACE: $stacktrace");
      throw e; // Repository에서 잡을 수 있도록 에러 다시 던지기
    }


  }

  // 정류소별 도착 예정 정보 목록 조회
  Future<List<BusArrivalInfo>> getArrivalInfoByStop({
    required String cityCode,
    required String nodeId,
  }) async {
    final queryParams = QueryParamBuilder(busApiServiceKey)
        .withParam('cityCode', cityCode)
        .withParam('nodeId', nodeId)
        .build();
    final data = await apiClient.fetchData(
      "/1613000/ArvlInfoInqireService/getSttnAcctoArvlPrearngeInfoList",
      queryParams,
    );
    List<dynamic> items = (data['response']['body']['items']['item'] as List<dynamic>?) ?? [];
    return items.map((item) => BusArrivalInfo.fromJson(item)).toList();
  }

  // 정류소별 특정 노선 버스 도착 예정 정보 목록 조회
  Future<List<BusArrivalInfo>> getArrivalInfoByRoute({
    required String cityCode,
    required String nodeId,
    required String routeId,
  }) async {
    final queryParams = QueryParamBuilder(busApiServiceKey)
        .withParam('cityCode', cityCode)
        .withParam('nodeId', nodeId)
        .withParam('routeId', routeId)
        .build();

    final data = await apiClient.fetchData(
      "/1613000/ArvlInfoInqireService/getSttnAcctoSpcifyRouteBusArvlPrearngeInfoList",
      queryParams,
    );
    List<dynamic> items = (data['response']['body']['items']['item'] as List<dynamic>?) ?? [];
    return items.map((item) => BusArrivalInfo.fromJson(item)).toList();
  }
}
