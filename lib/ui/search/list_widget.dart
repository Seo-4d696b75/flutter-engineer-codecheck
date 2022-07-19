import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class _FirstPageIndicator extends StatelessWidget {
  const _FirstPageIndicator({
    Key? key,
    required this.title,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 48,
            ),
            if (onRetry != null)
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  label: Text(
                    l.listRetryButton,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FirstPageError extends StatelessWidget {
  const FirstPageError({
    required this.onRetry,
    Key? key,
  }) : super(key: key);

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return _FirstPageIndicator(
      title: l.listFirstPageErrorTitle,
      message: l.listFirstPageErrorMessage,
      onRetry: onRetry,
    );
  }
}

class FirstPageNoItems extends StatelessWidget {
  const FirstPageNoItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return _FirstPageIndicator(
      title: l.listFirstPageNoItemsTitle,
      message: l.listFirstPageNoItemsMessage,
    );
  }
}

class NewPageError extends StatelessWidget {
  const NewPageError({Key? key, required this.onRetry}) : super(key: key);

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return InkWell(
      onTap: onRetry,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l.listNewPageErrorTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              width: 10,
            ),
            const Icon(
              Icons.refresh,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class NewPageProgress extends StatelessWidget {
  const NewPageProgress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 65,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
