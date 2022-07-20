import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_engineer_codecheck/gen/assets.gen.dart';
import 'package:flutter_engineer_codecheck/main.dart';
import 'package:flutter_engineer_codecheck/model/entities/repository_search_response.dart';
import 'package:flutter_engineer_codecheck/model/repository/search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../view_model/search_view_model_test.mocks.dart';
import 'matcher.dart';

@GenerateMocks([SearchRepository])
void main() {
  group("検索ページ WidgetTest", () {
    final str =
        File(Assets.test.json.searchRepositoryLinux10).readAsStringSync();
    final mockResponse = RepositorySearchResponse.fromJson(jsonDecode(str));

    testWidgets("SnackBar - 空の検索キーワード", (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MyApp(),
          overrides: [
            localeProvider.overrideWithValue(const Locale("ja", "JP")),
          ],
        ),
      );

      expect(find.text("リポジトリ検索"), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text("リポジトリが見つかりません"), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, "検索"));
      expect(find.text("検索キーワードが空白です！"), findsNothing);
      await tester.pump(); // eventをUiStateとして発行
      await tester.pump(); // page側でeventをhandleしてanimationをschedule
      expect(find.text("検索キーワードが空白です！"), findsOneWidget);
    });
    testWidgets("SnackBar - まだ検索中だから待て", (tester) async {
      final mockRepository = MockSearchRepository();
      final completer = Completer();
      when(mockRepository.search(
        query: anyNamed("query"),
        page: anyNamed("page"),
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        await completer.future; // 検索状態のまま待機させる
        throw StateError("no response for test");
      });

      await tester.pumpWidget(
        ProviderScope(
          child: const MyApp(),
          overrides: [
            localeProvider.overrideWithValue(const Locale("ja", "JP")),
            searchRepositoryProvider.overrideWithValue(mockRepository),
          ],
        ),
      );

      expect(find.text("リポジトリ検索"), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text("リポジトリが見つかりません"), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), "linux");

      // 1st tap
      await tester.tap(find.widgetWithText(ElevatedButton, "検索"));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 2nd tap
      await tester.tap(find.widgetWithText(ElevatedButton, "検索"));
      expect(find.text("現在検索中です…"), findsNothing);
      await tester.pump(); // eventをUiStateとして発行
      await tester.pump(); // page側でeventをhandleしてanimationをschedule
      expect(find.text("現在検索中です…"), findsOneWidget);
    });
    testWidgets("初回読み込み失敗 > Retry", (tester) async {
      final mockRepository = MockSearchRepository();
      final completer = Completer();
      when(mockRepository.search(
        query: anyNamed("query"),
        page: anyNamed("page"),
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        await completer.future; // 検索状態のまま待機させる
        throw Exception("test");
      });

      await tester.pumpWidget(
        ProviderScope(
          child: const MyApp(),
          overrides: [
            localeProvider.overrideWithValue(const Locale("ja", "JP")),
            searchRepositoryProvider.overrideWithValue(mockRepository),
          ],
        ),
      );

      expect(find.text("リポジトリ検索"), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text("リポジトリが見つかりません"), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), "linux");

      // 検索中はプログレスバー表示
      await tester.tap(find.widgetWithText(ElevatedButton, "検索"));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 検索の失敗
      completer.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text("エラー"), findsOneWidget);
      expect(find.text("データの取得に失敗しました. 再度お試しください."), findsOneWidget);

      // 再試行
      when(mockRepository.search(
        query: anyNamed("query"),
        page: anyNamed("page"),
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        return mockResponse;
      });

      await tester.tap(find.text("再試行"));
      await tester.pumpAndSettle();

      // 10件の表示（全部は表示されていない？）
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        find.byType(ListTile, skipOffstage: false),
        findsWidgetsMoreThan(1),
      );
    });
    testWidgets("検索結果0件", (tester) async {
      final mockRepository = MockSearchRepository();
      final completer = Completer();
      when(mockRepository.search(
        query: anyNamed("query"),
        page: anyNamed("page"),
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        await completer.future; // 検索状態のまま待機させる
        return RepositorySearchResponse(
          totalCount: 0,
          incompleteResults: false,
          items: [],
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          child: const MyApp(),
          overrides: [
            localeProvider.overrideWithValue(const Locale("ja", "JP")),
            searchRepositoryProvider.overrideWithValue(mockRepository),
          ],
        ),
      );

      expect(find.text("リポジトリ検索"), findsOneWidget);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), "linux");

      // 検索中はプログレスバー表示
      await tester.tap(find.widgetWithText(ElevatedButton, "検索"));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 検索結果0件
      completer.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text("リポジトリが見つかりません"), findsOneWidget);
      expect(find.text("他の検索キーワードをお試しください."), findsOneWidget);
    });
    testWidgets("追加読み込み失敗 > Retry", (tester) async {
      final mockRepository = MockSearchRepository();
      when(mockRepository.search(
        query: anyNamed("query"),
        page: 1,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        return mockResponse;
      });

      final completer = Completer();
      when(mockRepository.search(
        query: anyNamed("query"),
        page: 2,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        await completer.future;
        throw Exception("test");
      });

      await tester.pumpWidget(
        ProviderScope(
          child: const MyApp(),
          overrides: [
            localeProvider.overrideWithValue(const Locale("ja", "JP")),
            searchRepositoryProvider.overrideWithValue(mockRepository),
          ],
        ),
      );

      expect(find.text("リポジトリ検索"), findsOneWidget);

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), "linux");

      // 初回読み込み
      await tester.tap(find.widgetWithText(ElevatedButton, "検索"));
      await tester.pumpAndSettle();

      // 追加読み込み
      // 一番下（追加読み込みのプログレスバー）までスクロール
      final scrollable = find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      );
      await tester.scrollUntilVisible(
        find.byType(CircularProgressIndicator),
        100,
        scrollable: scrollable,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 追加読み込み失敗
      completer.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text("エラー！ タップして再試行"), findsOneWidget);

      // 再試行
      when(mockRepository.search(
        query: anyNamed("query"),
        page: 2,
        perPage: anyNamed("perPage"),
      )).thenAnswer((_) async {
        return mockResponse;
      });
      await tester.tap(find.text("エラー！ タップして再試行"));
      await tester.pumpAndSettle();

      // 10+more件の表示
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text("エラー！ タップして再試行"), findsNothing);
      expect(
        find.byType(ListTile, skipOffstage: false),
        findsWidgetsMoreThan(10),
      );
    });
  });
}
