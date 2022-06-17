import 'package:flutter_engineer_codecheck/model/repository/search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../model/entities/repository.dart';

final searchViewModelProvider =
    StateNotifierProvider.autoDispose<SearchViewModel, String>(
  (ref) => SearchViewModel(
    ref.watch(searchRepositoryProvider),
  ),
);

class SearchViewModel extends StateNotifier<String> {
  SearchViewModel(this._repository) : super("linux") {
    controller.addPageRequestListener((page) => _fetchPage(page));
  }

  final controller = PagingController<int, GithubRepository>(firstPageKey: 1);

  final pageSize = 10;
  final SearchRepository _repository;

  set query(String value) {
    state = value;
    _refreshQuery(value);
  }

  void onListItemSelected(GithubRepository item) {
    // TODO 詳細画面への遷移
  }

  Future<void> _refreshQuery(String value) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (state == value) {
      controller.refresh();
    }
  }

  Future<void> _fetchPage(int page) async {
    final query = state;
    if (query.isEmpty) {
      controller.appendLastPage([]);
      return;
    }
    try {
      final response = await _repository.search(
        query: query,
        page: page,
        perPage: pageSize,
      );
      if (page * pageSize < response.totalCount) {
        controller.appendPage(response.items, page + 1);
      } else {
        controller.appendLastPage(response.items);
      }
    } on Exception catch (e) {
      controller.error = e;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
