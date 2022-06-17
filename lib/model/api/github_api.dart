import 'dart:io';

import 'package:dio/dio.dart';

class GithubAPI {
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://api.github.com/"));

  Future<String> fetchRepository({
    required String query,
    int perPage = 30,
  }) async {
    final queryMap = {
      "q": query,
      "per_page": perPage,
    };
    final response = await _dio.get<String>(
      "/search/repository",
      queryParameters: queryMap,
    );
    final body = response.data;
    if (body == null) {
      throw const HttpException("response null");
    }
    return body;
  }
}
