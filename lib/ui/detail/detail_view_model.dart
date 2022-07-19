import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/entities/repository.dart';

final repositoryDetailViewModelProvider =
    StateNotifierProvider<RepositoryDetailViewModel, GithubRepository?>(
  (_) => RepositoryDetailViewModel(),
);

class RepositoryDetailViewModel extends StateNotifier<GithubRepository?> {
  RepositoryDetailViewModel({GithubRepository? repo}) : super(repo);

  void selectRepository(GithubRepository repository) {
    state = repository;
  }
}
