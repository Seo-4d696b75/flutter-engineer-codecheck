import 'package:flutter/material.dart';
import 'package:flutter_engineer_codecheck/ui/search/list_widget.dart';
import 'package:flutter_engineer_codecheck/ui/search/search_view_model.dart';
import 'package:flutter_engineer_codecheck/ui/search/search_view_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../model/entities/repository.dart';
import '../detail/detail_view_model.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.searchPageTitle),
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

class _SearchBox extends HookConsumerWidget {
  const _SearchBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(searchViewModelProvider.notifier);
    final events =
        ref.watch(searchViewModelProvider.select((state) => state.events));
    useEffect(
      () {
        if (events.isNotEmpty) {
          Future.microtask(() {
            // buildより後に実行する必要がある
            _handleEvents(context, events);
            viewModel.consumeEvents();
          });
        }
        return null;
      },
      [events],
    );
    final l = L10n.of(context);
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TextFormField(
              controller: viewModel.textController,
              textInputAction: TextInputAction.go,
              onFieldSubmitted: (value) => viewModel.search(),
              decoration: InputDecoration(
                labelText: l.searchQueryLabel,
                hintText: l.searchQueryHint,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
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
            child: Text(l.searchButtonText),
          ),
        ],
      ),
    );
  }

  void _handleEvents(BuildContext context, List<SearchViewEvent> events) {
    final l = L10n.of(context);
    for (final event in events) {
      event.maybeWhen(
        emptyQuery: () {
          final snackBar = SnackBar(
            content: Text(l.searchMessageEmptyQuery),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        waitSearch: () {
          final snackBar = SnackBar(
            content: Text(l.searchMessageWait),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        orElse: () {},
      );
    }
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
            onClick: () {
              ref
                  .read(repositoryDetailViewModelProvider.notifier)
                  .selectRepository(item);
              GoRouter.of(context).go("/repository");
            },
          ),
          firstPageErrorIndicatorBuilder: (_) => FirstPageError(
            onRetry: () => viewModel.pagingController.refresh(),
          ),
          noItemsFoundIndicatorBuilder: (_) => const FirstPageNoItems(),
          newPageProgressIndicatorBuilder: (_) => const NewPageProgress(),
          newPageErrorIndicatorBuilder: (_) => NewPageError(
            onRetry: () => viewModel.pagingController.retryLastFailedRequest(),
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
