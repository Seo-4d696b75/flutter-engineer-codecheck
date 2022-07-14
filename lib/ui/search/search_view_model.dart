import 'package:flutter/cupertino.dart';
import 'package:flutter_engineer_codecheck/model/repository/search_repository.dart';
import 'package:flutter_engineer_codecheck/ui/search/search_view_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../model/entities/repository.dart';

final searchViewModelProvider =
    StateNotifierProvider.autoDispose<SearchViewModel, SearchViewState>(
  (ref) => SearchViewModel(
    ref.watch(searchRepositoryProvider),
  ),
);

class SearchViewModel extends StateNotifier<SearchViewState> {
  SearchViewModel(this._repository)
      : super(SearchViewState(
          query: "",
          events: [],
        )) {
    pagingController.addPageRequestListener((page) => _fetchPage(page));
  }

  final textController = TextEditingController(text: "");
  final pagingController =
      PagingController<int, GithubRepository>(firstPageKey: 1);

  final pageSize = 10;
  final SearchRepository _repository;

  void search() {
    final query = textController.value.text;
    state = state.copyWith(query: query);
    if (query.isEmpty) {
      state = state.enqueueEvent(SearchViewEvent.emptyQuery());
    } else if (pagingController.value.status == PagingStatus.loadingFirstPage) {
      state = state.enqueueEvent(SearchViewEvent.waitSearch());
    } else {
      pagingController.refresh();
    }
  }

  void consumeEvents() {
    state = state.copyWith(events: []);
  }

  Future<void> _fetchPage(int page) async {
    final query = state.query;
    await Future<void>.delayed(const Duration(milliseconds: 5000));
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
