import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_engineer_codecheck/model/api/github_api.dart';
import 'package:flutter_engineer_codecheck/model/entities/repository.dart';
import 'package:flutter_engineer_codecheck/model/entities/repository_search_response.dart';
import 'package:flutter_engineer_codecheck/model/repository/search_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  group("SearchRepositoryでJSONをパース", () {
    final dio = Dio(BaseOptions(baseUrl: "https://api.github.com"));
    final adapter = DioAdapter(dio: dio);
    final testQueryParams = <String, dynamic>{
      "page": 1,
      "q": "test",
      "per_page": 10,
    };
    final api = GithubAPI(dio);
    final repository = SearchRepository(api);

    test("空リスト", () async {
      // prepare
      final mockResponse = {
        "total_count": 0,
        "incomplete_results": false,
        "items": [],
      };
      adapter.onGet(
        "/search/repositories",
        (server) => server.reply(200, mockResponse),
        queryParameters: testQueryParams,
      );

      // test
      final response = await repository.search(
        query: "test",
        page: 1,
        perPage: 10,
      );

      // verify
      expect(response.totalCount, 0);
      expect(response.items.length, 0);
    });
    test("repository x 10", () async {
      // prepare
      final str =
          File("test/json/search_repository_linux_10.json").readAsStringSync();
      final mockResponse = RepositorySearchResponse.fromJson(jsonDecode(str));
      adapter.onGet(
        "/search/repositories",
        (server) => server.reply(200, mockResponse),
        queryParameters: testQueryParams,
      );

      // test
      final response = await repository.search(
        query: "test",
        page: 1,
        perPage: 10,
      );

      // verify
      expect(response.totalCount, 294057);
      expect(response.items.length, 10);
      expect(response.items, isA<List<GithubRepository>>());
    });
  });
}
