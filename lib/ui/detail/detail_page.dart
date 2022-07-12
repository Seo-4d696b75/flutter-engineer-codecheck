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
                Container(width: 10),
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
            Container(height: 20),
            const _FeatureTitle("About"),
            _RepositoryFeature(
              Assets.img.star.svg(),
              repository.stargazersCount.toString(),
              " star",
            ),
            _RepositoryFeature(
              Assets.img.watch.svg(),
              repository.watchersCount.toString(),
              " watching",
            ),
            _RepositoryFeature(
              Assets.img.fork.svg(),
              repository.forksCount.toString(),
              " forks",
            ),
            _RepositoryFeature(
              Assets.img.issue.svg(),
              repository.openIssuesCount.toString(),
              " open issues",
            ),
            const _FeatureTitle("language"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(repository.language ?? "no information"),
            ),
            const _FeatureTitle("description"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(repository.description ?? "no description"),
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
    if (url == null) {
      return const SizedBox.square(
        dimension: 100,
        child: Icon(Icons.perm_identity),
      );
    }
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        image: DecorationImage(
          fit: BoxFit.contain,
          image: NetworkImage(url),
        ),
      ),
    );
  }
}

class _FeatureTitle extends StatelessWidget {
  const _FeatureTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _RepositoryFeature extends StatelessWidget {
  const _RepositoryFeature(this._icon, this._value, this._suffix);

  final Widget _icon;
  final String _value;
  final String _suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 24,
            child: _icon,
          ),
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 18,
                ),
                children: [
                  TextSpan(
                    text: _value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: _suffix),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
