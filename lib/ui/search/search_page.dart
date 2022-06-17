import 'package:flutter/material.dart';
import 'package:flutter_engineer_codecheck/ui/search/search_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../model/entities/repository.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _List(),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(searchViewModelProvider.notifier);
    return PagedListView(
      pagingController: viewModel.controller,
      builderDelegate: PagedChildBuilderDelegate<GithubRepository>(
        itemBuilder: (context, item, index) => ListTile(
          title: Text(item.fullName),
          subtitle: Text(item.owner?.login ?? ""),
        ),
      ),
    );
  }
}
