
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../text/labels.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final AscentStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      Draft() => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      Proposed() => (const Color(0xFFFDF0DB), const Color(0xFF8A5A12)),
      Confirmed() => (const Color(0xFFE7EEFB), const Color(0xFF2F5FA8)),
      Published() => (const Color(0xFFE2F3E4), const Color(0xFF2A6B33)),
      Rejected() => (const Color(0xFFFBE3E1), const Color(0xFFA33A32)),
      Archived() => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        statusLabel(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground, fontWeight: FontWeight.w700),
      ),
    );
  }
}