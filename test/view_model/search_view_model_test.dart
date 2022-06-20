import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
        File("test/json/search_repository_linux_10.json").readAsStringSync();
    final mockResponse = RepositorySearchResponse.fromJson(jsonDecode(str));

    test("初期状態", () {
      // prepare
      final viewModel = SearchViewModel(mockRepository);

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
      final viewModel = SearchViewModel(mockRepository);
      final completer = Completer<void>();
      when(mockRepository.search(
        query: query,
        page: 1,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        await completer.future;
        return mockResponse;
      });

      // test & verify
      viewModel.query = query;
      // widgetからの呼び出しがないため明示的にコール
      viewModel.pagingController.notifyPageRequestListeners(1);
      expect(
        viewModel.pagingController.value.status,
        PagingStatus.loadingFirstPage,
      );

      // complete loading
      completer.complete();
      // TODO avoid delay!!
      await Future.delayed(const Duration(milliseconds: 100));
      expect(
        viewModel.pagingController.itemList?.length,
        mockResponse.items.length,
      );
      expect(
        viewModel.pagingController.value.status,
        PagingStatus.ongoing,
      );
      expect(
        viewModel.pagingController.value.nextPageKey,
        2,
      );
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
      final viewModel = SearchViewModel(mockRepository);
      when(mockRepository.search(
        query: query,
        page: 1,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        return mockResponse;
      });

      // first loading
      viewModel.query = query;
      viewModel.pagingController.notifyPageRequestListeners(1);
      // TODO avoid delay!!
      await Future.delayed(const Duration(milliseconds: 100));

      // prepare
      final completer = Completer<void>();
      when(mockRepository.search(
        query: query,
        page: 2,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        await completer.future;
        return mockResponse.copyWith(
          // nextPageなし
          totalCount: mockResponse.items.length * 2,
        );
      });

      // test & verify
      viewModel.pagingController.notifyPageRequestListeners(2);
      expect(
        viewModel.pagingController.value.status,
        PagingStatus.ongoing,
      );

      // complete loading
      completer.complete();
      // TODO avoid delay!!
      await Future.delayed(const Duration(milliseconds: 100));
      expect(
        viewModel.pagingController.itemList?.length,
        mockResponse.items.length * 2,
      );
      expect(
        viewModel.pagingController.value.status,
        PagingStatus.completed,
      );
      expect(
        viewModel.pagingController.value.nextPageKey,
        isNull,
      );
    });

    test("初回読み込み失敗", () async {
      // prepare
      final viewModel = SearchViewModel(mockRepository);
      when(mockRepository.search(
        query: query,
        page: 1,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        throw const HttpException("test");
      });

      // test & verify
      viewModel.query = query;
      viewModel.pagingController.notifyPageRequestListeners(1);

      // TODO avoid delay!!
      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        viewModel.pagingController.value.status,
        PagingStatus.firstPageError,
      );
      expect(
        viewModel.pagingController.itemList,
        isNull,
      );
    });
    test("追加読み込み失敗", () async {
      // prepare (first-loading)
      final viewModel = SearchViewModel(mockRepository);
      when(mockRepository.search(
        query: query,
        page: 1,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        return mockResponse;
      });
      viewModel.query = query;
      viewModel.pagingController.notifyPageRequestListeners(1);
      // TODO avoid delay!!
      await Future.delayed(const Duration(milliseconds: 100));

      // prepare (additional-loading)
      when(mockRepository.search(
        query: query,
        page: 2,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        throw const HttpException("test");
      });

      // test & verify
      viewModel.pagingController.notifyPageRequestListeners(2);

      // TODO avoid delay!!
      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        viewModel.pagingController.value.status,
        PagingStatus.subsequentPageError,
      );
      expect(
        viewModel.pagingController.itemList?.length,
        mockResponse.items.length,
      );
    });
  });
}
