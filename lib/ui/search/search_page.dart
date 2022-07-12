import 'package:flutter/material.dart';
import 'package:flutter_engineer_codecheck/ui/search/search_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../model/entities/repository.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Repository"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: const [
          _SearchBox(),
          Expanded(child: _List()),
        ],
      ),
      backgroundColor: const Color.fromARGB(230, 255, 255, 255),
    );
  }
}

class _SearchBox extends ConsumerWidget {
  const _SearchBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(searchViewModelProvider.notifier);
    return Container(
      height: 50,
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text("Input Query"),
          Container(width: 10),
          Expanded(
            child: TextFormField(
              controller: viewModel.textController,
              textInputAction: TextInputAction.go,
              onFieldSubmitted: (value) => viewModel.query = value,
            ),
          ),
          Container(width: 20),
          ElevatedButton(
            onPressed: () {
              final currentScope = FocusScope.of(context);
              if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
              viewModel.search();
            },
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(searchViewModelProvider.notifier);
    return RefreshIndicator(
      child: PagedListView(
        pagingController: viewModel.pagingController,
        builderDelegate: PagedChildBuilderDelegate<GithubRepository>(
          itemBuilder: (context, item, index) => _ListItem(
            item: item,
            onClick: () => viewModel.onListItemSelected(item),
          ),
        ),
      ),
      onRefresh: () async => viewModel.pagingController.refresh(),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({required this.item, required this.onClick});

  final GithubRepository item;
  final void Function() onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClick,
      child: Card(
        child: ListTile(
          title: Text(item.fullName),
          subtitle: Text(item.owner?.login ?? ""),
        ),
      ),
    );
  }
}
