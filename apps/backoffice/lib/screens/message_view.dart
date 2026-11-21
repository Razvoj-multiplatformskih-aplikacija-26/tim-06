
import 'package:flutter/material.dart';

class MessageView extends StatelessWidget {
  const MessageView({required this.icon, required this.title, this.action});

  final IconData icon;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}