import 'package:dio/dio.dart';
import 'package:flutter_project/src/data/api_client.dart';

class DioApiClient implements ApiClient {
  final Dio _dio = Dio();
  final String baseUrl;

  DioApiClient({required this.baseUrl}) {
    // interceptor 추가 (선택 사항) - 요청/응답 로깅 등
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Dio: Request ${options.method} ${options.uri}');
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

  @override
  Future<dynamic> fetchData(String apiPath, Map<String, dynamic> queryParams) async {
    try {
      final uri = Uri.https(baseUrl, apiPath, queryParams);
      final response = await _dio.getUri(
        uri,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      return response.data; // Dio는 이미 파싱된 데이터를 제공합니다.
    } on DioException catch (e) {
      print("DIO: An error occurred: $e");
      throw e; // 에러를 다시 던져서 상위 레이어에서 처리하도록 합니다.
    }
  }
}
