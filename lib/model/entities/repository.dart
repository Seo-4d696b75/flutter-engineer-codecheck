import 'package:flutter_engineer_codecheck/model/entities/repository_owner.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'repository.freezed.dart';

part 'repository.g.dart';

@freezed
class GithubRepository with _$GithubRepository {
  factory GithubRepository({
    required int id,
    required String name,
    required String fullName,
    required String? description,
    required String? language,
    required int stargazersCount,
    required int watchersCount,
    required int forksCount,
    required int openIssuesCount,
    GithubRepositoryOwner? owner,
  }) = _GithubRepository;

  factory GithubRepository.fromJson(Map<String, Object?> json) =>
      _$GithubRepositoryFromJson(json);
}
