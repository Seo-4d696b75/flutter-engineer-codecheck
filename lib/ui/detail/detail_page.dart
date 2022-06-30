import 'package:flutter/material.dart';
import 'package:flutter_engineer_codecheck/gen/assets.gen.dart';
import 'package:flutter_engineer_codecheck/ui/detail/detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/entities/repository_owner.dart';

class RepositoryDetailPage extends StatelessWidget {
  const RepositoryDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Repository"),
      ),
      body: _RepositoryDetail(),
      backgroundColor: Colors.white,
    );
  }
}

class _RepositoryDetail extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(repositoryDetailViewModelProvider);
    if (repository == null) {
      throw StateError("repository not selected");
    }
    return Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                _OwnerIcon(repository.owner),
                Expanded(
                  child: Text(
                    repository.fullName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            _RepositoryFeature(
              Assets.img.star.svg(),
              "${repository.stargazersCount} star",
            ),
            _RepositoryFeature(
              Assets.img.watch.svg(),
              "${repository.watchersCount} watching",
            ),
            _RepositoryFeature(
              Assets.img.fork.svg(),
              "${repository.forksCount} forks",
            ),
            _RepositoryFeature(
              Assets.img.issue.svg(),
              "${repository.openIssuesCount} open issues",
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(5),
              child: const Text(
                "language",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              child: Text(repository.language ?? ""),
            ),
          ],
        ));
  }
}

class _OwnerIcon extends StatelessWidget {
  const _OwnerIcon(this.owner);

  final GithubRepositoryOwner? owner;

  @override
  Widget build(BuildContext context) {
    final url = owner?.avatarUrl;
    return SizedBox.square(
      dimension: 100,
      child: url == null
          ? const Icon(
              Icons.perm_identity,
            )
          : Image.network(
              url,
            ),
    );
  }
}

class _RepositoryFeature extends StatelessWidget {
  const _RepositoryFeature(this._icon, this._text);

  final Widget _icon;
  final String _text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 20,
            child: _icon,
          ),
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: Text(
              _text,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
    );
  }
}
