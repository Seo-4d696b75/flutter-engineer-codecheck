import 'package:flutter/material.dart';
import 'package:flutter_engineer_codecheck/main.dart';
import 'package:flutter_engineer_codecheck/model/entities/repository.dart';
import 'package:flutter_engineer_codecheck/router.dart';
import 'package:flutter_engineer_codecheck/ui/detail/detail_page.dart';
import 'package:flutter_engineer_codecheck/ui/detail/detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  group("詳細ページ WidgetTest", () {
    final testRouter = GoRouter(routes: [
      GoRoute(
        path: "/",
        builder: (context, state) => const RepositoryDetailPage(),
      ),
    ]);
    testWidgets("ja", (tester) async {
      final repository = GithubRepository(
        id: 0,
        name: "test-repository",
        fullName: "test/test-repository",
        description: "this is a repository for widget test",
        language: null,
        stargazersCount: 10,
        watchersCount: 1,
        forksCount: 0,
        openIssuesCount: 5,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routerProvider.overrideWithValue(testRouter),
            localeProvider.overrideWithValue(const Locale("ja", "JP")),
            repositoryDetailViewModelProvider.overrideWithValue(
              RepositoryDetailViewModel(repo: repository),
            ),
          ],
          child: const MyApp(),
        ),
      );

      expect(find.text("リポジトリ詳細"), findsOneWidget);
      expect(find.text(repository.fullName), findsOneWidget);

      expect(find.text("10個のStar"), findsOneWidget);
      expect(find.text("1人がWatch"), findsOneWidget);
      expect(find.text("0件のFork"), findsOneWidget);
      expect(find.text("5個のオープンなIssue"), findsOneWidget);

      expect(find.text("情報がありません"), findsOneWidget);
      expect(find.text(repository.description ?? ""), findsOneWidget);
    });

    testWidgets("en", (tester) async {
      final repository = GithubRepository(
        id: 0,
        name: "test-repository",
        fullName: "test/test-repository",
        description: null,
        language: "dart",
        stargazersCount: 10,
        watchersCount: 1,
        forksCount: 0,
        openIssuesCount: 5,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routerProvider.overrideWithValue(testRouter),
            localeProvider.overrideWithValue(const Locale("en", "US")),
            repositoryDetailViewModelProvider.overrideWithValue(
              RepositoryDetailViewModel(repo: repository),
            ),
          ],
          child: const MyApp(),
        ),
      );

      expect(find.text("Repository"), findsOneWidget);
      expect(find.text(repository.fullName), findsOneWidget);

      expect(find.text("10 star"), findsOneWidget);
      expect(find.text("1 watching"), findsOneWidget);
      expect(find.text("0 forks"), findsOneWidget);
      expect(find.text("5 open issue"), findsOneWidget);

      expect(find.text("dart"), findsOneWidget);
      expect(find.text("no description"), findsOneWidget);
    });
  });
}
