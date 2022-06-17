import 'dart:convert';

import 'package:flutter_engineer_codecheck/model/api/github_api.dart';
import 'package:flutter_engineer_codecheck/model/entities/repository_search_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchRepositoryProvider = Provider(
  (ref) => SearchRepository(
    ref.watch(githubApiProvider),
  ),
);

class SearchRepository {
  SearchRepository(this._api);

  final GithubAPI _api;

  Future<RepositorySearchResponse> search({
    required String query,
    required int page,
    int perPage = 30,
  }) async {
    final body = await _api.fetchRepository(
      query: query,
      page: page,
      perPage: perPage,
    );
    final json = jsonDecode(body);
    return RepositorySearchResponse.fromJson(json);
  }
}
