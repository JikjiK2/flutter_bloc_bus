import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';

class BusLocationApi {
  final String busApiServiceKey;
  final String cityCode;
  final String routeId;

  final String baseUrl = "apis.data.go.kr";
  final String apiPath =
      "/1613000/BusLcInfoInqireService/getRouteAcctoBusLcList";

  final Dio _dio = Dio();

  BusLocationApi({
    required this.busApiServiceKey,
    required this.cityCode,
    required this.routeId,
  }) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('DIO: Request[${options.method}] ${options.uri}');
          return handler.next(options); // 요청 진행
        },
        onResponse: (response, handler) {
          print(
            'DIO: Response[${response.statusCode}] ${response.requestOptions.uri}',
          );
          return handler.next(response); // 응답 진행
        },
        onError: (DioException e, handler) {
          print(
            'DIO: Error[${e.response?.statusCode}] ${e.requestOptions.uri}',
          );
          return handler.next(e); // 에러 진행
        },
      ),
    );
  }

  Future<List<dynamic>?> fetchBusLocation() async {
    try {
      final queryParameters = createQueryParameters(busApiServiceKey, {
        "pageNo": "1",
        "numOfRows": "1",
        "cityCode": cityCode,
        "routeId": routeId,
      });
      final Uri uri = Uri.https(baseUrl, apiPath, queryParameters);

      final response = await _dio.getUri(
        uri,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final decodedJson = response.data;

        if (decodedJson['response'] != null &&
            decodedJson['response']['body'] != null &&
            decodedJson['response']['body']['items'] != null) {
          final items = decodedJson['response']['body']['items']['item'];
          if (items != null) {
            return [items]; // item이 리스트로 감싸진 형태로 반환
          } else {
            return []; // 데이터가 없는 경우 빈 리스트 반환
          }
        } else {
          print("DIO: Unexpected API response structure");
          throw Exception('Unexpected API response structure');
        }
      } else {
        print("DIO: API Request Failed: ${response.statusCode}");
        throw Exception('API Request Failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      handleDioError(e);
      return null;
    } catch (e) {
      print("DIO: An error occurred: $e");
      throw Exception('API Request Error: $e');
    }
  }
}

class BusStopFindApi {
  final String busApiServiceKey;
  final String gpsLati;
  final String gpsLong;

  final String baseUrl = "apis.data.go.kr";
  final String apiPath =
      "/1613000/BusLcInfoInqireService/BusSttnInfoInqireService";

  final Dio _dio = Dio();

  BusStopFindApi({
    required this.busApiServiceKey,
    required this.gpsLati,
    required this.gpsLong,
  }) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Dio: Request ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Dio: Response ${response.statusCode} ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('Dio: Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<List<dynamic>?> fetchBusStop() async {
    try {
      final queryParameters = createQueryParameters(busApiServiceKey, {
        "gpsLati": gpsLati,
        "gpsLong": gpsLong,
        "pageNo": "1",
        "numOfRows": "1",
      });
      final Uri uri = Uri.https(baseUrl, apiPath, queryParameters);

      final response = await _dio.getUri(
        uri,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final decodedJson = response.data;

        if (decodedJson['response'] != null &&
            decodedJson['response']['body'] != null &&
            decodedJson['response']['body']['items'] != null) {
          final items = decodedJson['response']['body']['items']['item'];
          if (items != null) {
            return [items]; // item이 리스트로 감싸진 형태로 반환
          } else {
            return []; // 데이터가 없는 경우 빈 리스트 반환
          }
        } else {
          print("DIO: Unexpected API response structure");
          throw Exception('Unexpected API response structure');
        }
      } else {
        print("DIO: API Request Failed: ${response.statusCode}");
        throw Exception('API Request Failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      handleDioError(e);
      return null;
    } catch (e) {
      print("DIO: An error occurred: $e");
      throw Exception('API Request Error: $e');
    }
  }
}

class BusRouteApi {
  final String busApiServiceKey;
  final String gpsLati;
  final String gpsLong;

  final String baseUrl = "apis.data.go.kr";
  final String apiPath =
      "/1613000/BusLcInfoInqireService/BusSttnInfoInqireService";

  final Dio _dio = Dio();

  BusRouteApi({
    required this.busApiServiceKey,
    required this.gpsLati,
    required this.gpsLong,
  }) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Dio: Request ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Dio: Response ${response.statusCode} ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('Dio: Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<List<dynamic>?> fetchBusStop() async {
    try {
      final queryParameters = createQueryParameters(busApiServiceKey, {
        "gpsLati": gpsLati,
        "gpsLong": gpsLong,
        "pageNo": "1",
        "numOfRows": "1",
      });
      final Uri uri = Uri.https(baseUrl, apiPath, queryParameters);

      final response = await _dio.getUri(
        uri,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final decodedJson = response.data;

        if (decodedJson['response'] != null &&
            decodedJson['response']['body'] != null &&
            decodedJson['response']['body']['items'] != null) {
          final items = decodedJson['response']['body']['items']['item'];
          if (items != null) {
            return [items]; // item이 리스트로 감싸진 형태로 반환
          } else {
            return []; // 데이터가 없는 경우 빈 리스트 반환
          }
        } else {
          print("DIO: Unexpected API response structure");
          throw Exception('Unexpected API response structure');
        }
      } else {
        print("DIO: API Request Failed: ${response.statusCode}");
        throw Exception('API Request Failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      handleDioError(e);
      return null;
    } catch (e) {
      print("DIO: An error occurred: $e");
      throw Exception('API Request Error: $e');
    }
  }
}

Map<String, dynamic> createQueryParameters(
  String apiKey,
  Map<String, dynamic> additionalParams,
) {
  final Map<String, dynamic> queryParameters = {
    "serviceKey": apiKey,
    "_type": "json",
    ...additionalParams, // 나머지 파라미터 추가
  };
  return queryParameters;
}

// 공통 에러 처리 함수
void handleDioError(DioException e) {
  print("DIO: An error occurred: $e");
  if (e.type == DioExceptionType.connectionTimeout) {
    throw Exception('Connection Timeout: $e');
  } else if (e.type == DioExceptionType.receiveTimeout) {
    throw Exception('Receive Timeout: $e');
  } else if (e.response != null) {
    throw Exception('API Server Error: ${e.response!.statusCode}');
  }
  throw Exception('Error during API request: $e');
}
