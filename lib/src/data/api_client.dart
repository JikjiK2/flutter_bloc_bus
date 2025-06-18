
abstract class ApiClient {
  Future<dynamic> fetchData(String apiPath, Map<String, dynamic> queryParameters);
}
