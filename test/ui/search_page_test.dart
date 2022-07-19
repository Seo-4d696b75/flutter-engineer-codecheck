import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_engineer_codecheck/main.dart';
import 'package:flutter_engineer_codecheck/model/repository/search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../view_model/search_view_model_test.mocks.dart';

@GenerateMocks([SearchRepository])
void main() {
  group("検索ページ WidgetTest", () {
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
  });
}
