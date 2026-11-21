import 'package:flutter/material.dart';
import 'package:ui_text/ui_text.dart';
import 'package:use_cases/use_cases.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label = 'Ucitavanje'});

  final String label;

  @override
  Widget build(BuildContext context) =>
      Center(child: CircularProgressIndicator(semanticsLabel: label));
}

/// Ekran koji kaze sta se desilo i nudi ponovni pokusaj. Postoji da aplikacija
/// nikada ne bi ostala u ucitavanju bez kraja kada server ne radi.
class FailureView extends StatelessWidget {
  const FailureView({super.key, required this.failure, this.onRetry});

  final RepositoryFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(failureMessage(failure), textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onRetry, child: const Text('Pokusaj ponovo')),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
