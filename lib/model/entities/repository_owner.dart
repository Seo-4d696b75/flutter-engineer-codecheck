import 'package:freezed_annotation/freezed_annotation.dart';

part 'repository_owner.freezed.dart';

part 'repository_owner.g.dart';

@freezed
class GithubRepositoryOwner with _$GithubRepositoryOwner {
  factory GithubRepositoryOwner({
    required int id,
    required String login,
    required String avatarUrl,
  }) = _GithubRepositoryOwner;

  factory GithubRepositoryOwner.fromJson(Map<String, Object?> json) =>
      _$GithubRepositoryOwnerFromJson(json);
}
