import 'package:flutter/cupertino.dart';
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
    pagingController.addPageRequestListener((page) => _fetchPage(page));
  }

  final textController = TextEditingController(text: "linux");
  final pagingController =
      PagingController<int, GithubRepository>(firstPageKey: 1);

  final pageSize = 10;
  final SearchRepository _repository;

  set query(String value) {
    state = value;
    pagingController.refresh();
  }

  Future<void> _fetchPage(int page) async {
    final query = state;
    if (query.isEmpty) {
      pagingController.appendLastPage([]);
      return;
    }
    try {
      final response = await _repository.search(
        query: query,
        page: page,
        perPage: pageSize,
      );
      if (page * pageSize < response.totalCount) {
        pagingController.appendPage(response.items, page + 1);
      } else {
        pagingController.appendLastPage(response.items);
      }
    } on Exception catch (e) {
      pagingController.error = e;
    }
  }

  @override
  void dispose() {
    pagingController.dispose();
    textController.dispose();
    super.dispose();
    debugPrint("dispose controller");
  }
}
