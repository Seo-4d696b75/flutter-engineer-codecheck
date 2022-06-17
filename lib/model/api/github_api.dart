import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_engineer_codecheck/model/api/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final githubApiProvider = Provider(
  (ref) => GithubAPI(
    ref.watch(dioProvider),
  ),
);

class GithubAPI {
  GithubAPI(this._dio);

  final Dio _dio;

  Future<String> fetchRepository({
    required String query,
    required int page,
    int perPage = 30,
  }) async {
    final queryMap = {
      "q": query,
      "page": page,
      "per_page": perPage,
    };
    final response = await _dio.get<String>(
      "/search/repositories",
      queryParameters: queryMap,
    );
    final body = response.data;
    if (body == null) {
      throw const HttpException("response null");
    }
    return body;
  }
}
