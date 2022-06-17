import 'package:flutter_engineer_codecheck/model/entities/repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'repository_search_response.freezed.dart';

part 'repository_search_response.g.dart';

/// [Github API Search repository](https://docs.github.com/ja/rest/search#search-repositories)
@freezed
class RepositorySearchResponse with _$RepositorySearchResponse {
  factory RepositorySearchResponse({
    required int totalCount,
    required bool incompleteResults,
    required List<GithubRepository> items,
  }) = _RepositorySearchResponse;

  factory RepositorySearchResponse.fromJson(Map<String, Object?> json) =>
      _$RepositorySearchResponseFromJson(json);
}
