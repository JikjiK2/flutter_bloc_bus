class QueryParamBuilder {
  final Map<String, dynamic> params = {};

  QueryParamBuilder(String apiKey) {
    params['serviceKey'] = apiKey;
    params['_type'] = 'json'; // 기본 설정
  }

  QueryParamBuilder withParam(String key, dynamic value) {
    if (value != null) { // null 값은 추가하지 않음
      params[key] = value;
    }
    return this;
  }

  Map<String, dynamic> build() => params;
}
