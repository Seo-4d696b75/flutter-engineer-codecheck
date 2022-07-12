import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/entities/repository.dart';

final repositoryDetailViewModelProvider =
    StateNotifierProvider<RepositoryDetailViewModel, GithubRepository?>(
  (_) => RepositoryDetailViewModel(),
);

class RepositoryDetailViewModel extends StateNotifier<GithubRepository?> {
  RepositoryDetailViewModel() : super(null);

  void selectRepository(GithubRepository repository) {
    state = repository;
  }
}
