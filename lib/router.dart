import 'package:flutter_engineer_codecheck/ui/detail/detail_page.dart';
import 'package:flutter_engineer_codecheck/ui/search/search_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider(
  (ref) => GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SearchPage(),
        routes: [
          GoRoute(
            path: 'repository',
            builder: (context, builder) => const RepositoryDetailPage(),
          )
        ],
      ),
    ],
  ),
);
