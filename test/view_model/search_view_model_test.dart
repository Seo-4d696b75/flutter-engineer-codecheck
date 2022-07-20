import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_engineer_codecheck/gen/assets.gen.dart';
import 'package:flutter_engineer_codecheck/model/entities/repository_search_response.dart';
import 'package:flutter_engineer_codecheck/model/repository/search_repository.dart';
import 'package:flutter_engineer_codecheck/ui/search/search_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'search_view_model_test.mocks.dart';

@GenerateMocks([SearchRepository])
void main() {
  group("SearchViewModel", () {
    final mockRepository = MockSearchRepository();
    const query = "test-query";
    final str =
        File(Assets.test.json.searchRepositoryLinux10).readAsStringSync();
    final mockResponse = RepositorySearchResponse.fromJson(jsonDecode(str));

    Future<void> waitUntil(
      SearchViewModel viewModel,
      PagingStatus status,
    ) {
      final wait = Completer<void>();
      viewModel.pagingController.addStatusListener((s) {
        if (s == status) {
          viewModel.pagingController.value.status;
          wait.complete();
        }
      });
      return wait.future;
    }

    final mockListener = MockListener<PagingStatus>();

    SearchViewModel getViewModel() {
      final v = SearchViewModel(mockRepository);
      // 最初の状態もcallする
      mockListener.call(v.pagingController.value.status);
      v.pagingController.addStatusListener(mockListener);
      addTearDown(v.dispose);
      return v;
    }

    test("初期状態", () {
      // prepare
      final viewModel = getViewModel();

      // verify
      expect(viewModel.pagingController.itemList, isNull);
      verifyNever(
        mockRepository.search(
          query: anyNamed("query"),
          page: anyNamed("page"),
          perPage: anyNamed("perPage"),
        ),
      );
    });
    test("初回読み込み", () async {
      // prepare
      final viewModel = getViewModel();
      when(mockRepository.search(
        query: query,
        page: 1,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async => mockResponse);

      // test
      viewModel.textController.text = query;
      viewModel.search();
      // widgetからの呼び出しがないため明示的にコール
      viewModel.pagingController.notifyPageRequestListeners(1);
      await waitUntil(viewModel, PagingStatus.ongoing);

      // verify
      expect(
        viewModel.pagingController.itemList?.length,
        mockResponse.items.length,
      );
      expect(
        viewModel.pagingController.value.nextPageKey,
        2,
      );
      verifyInOrder([
        mockListener.call(PagingStatus.loadingFirstPage),
        mockListener.call(PagingStatus.ongoing),
      ]);
      verify(
        mockRepository.search(
          query: query,
          page: 1,
          perPage: anyNamed("perPage"),
        ),
      ).called(1);
    });
    test("追加読み込み", () async {
      // prepare
      final viewModel = getViewModel();
      when(mockRepository.search(
        query: query,
        page: 1,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async => mockResponse);

      // first loading
      viewModel.textController.text = query;
      viewModel.search();
      viewModel.pagingController.notifyPageRequestListeners(1);
      await waitUntil(viewModel, PagingStatus.ongoing);

      // prepare
      when(mockRepository.search(
        query: query,
        page: 2,
        perPage: anyNamed("perPage"),
      )).thenAnswer(
        (_) async => mockResponse.copyWith(
          // nextPageなし
          totalCount: mockResponse.items.length * 2,
        ),
      );

      // test
      viewModel.pagingController.notifyPageRequestListeners(2);
      await waitUntil(viewModel, PagingStatus.completed);

      // verify
      expect(
        viewModel.pagingController.itemList?.length,
        mockResponse.items.length * 2,
      );
      expect(
        viewModel.pagingController.value.nextPageKey,
        isNull,
      );
      verifyInOrder([
        mockListener.call(PagingStatus.loadingFirstPage),
        mockListener.call(PagingStatus.ongoing),
        mockListener.call(PagingStatus.completed),
      ]);
    });

    test("初回読み込み失敗", () async {
      // prepare
      final viewModel = getViewModel();
      when(mockRepository.search(
        query: query,
        page: 1,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        throw const HttpException("test");
      });

      // test
      viewModel.textController.text = query;
      viewModel.search();
      viewModel.pagingController.notifyPageRequestListeners(1);

      await waitUntil(viewModel, PagingStatus.firstPageError);

      // verify
      expect(
        viewModel.pagingController.itemList,
        isNull,
      );
      verifyInOrder([
        mockListener.call(PagingStatus.loadingFirstPage),
        mockListener.call(PagingStatus.firstPageError),
      ]);
    });
    test("追加読み込み失敗", () async {
      // prepare (first-loading)
      final viewModel = getViewModel();
      when(mockRepository.search(
        query: query,
        page: 1,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async => mockResponse);
      viewModel.textController.text = query;
      viewModel.search();
      viewModel.pagingController.notifyPageRequestListeners(1);
      await waitUntil(viewModel, PagingStatus.ongoing);

      // prepare (additional-loading)
      when(mockRepository.search(
        query: query,
        page: 2,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        throw const HttpException("test");
      });

      // test
      viewModel.pagingController.notifyPageRequestListeners(2);
      await waitUntil(viewModel, PagingStatus.subsequentPageError);

      // verify
      expect(
        viewModel.pagingController.value.status,
        PagingStatus.subsequentPageError,
      );
      expect(
        viewModel.pagingController.itemList?.length,
        mockResponse.items.length,
      );
      verifyInOrder([
        mockListener.call(PagingStatus.loadingFirstPage),
        mockListener.call(PagingStatus.ongoing),
        mockListener.call(PagingStatus.subsequentPageError),
      ]);
    });
  });
}

class MockListener<T> extends Mock {
  void call(T? value);
}
