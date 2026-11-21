
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:fake_data/fake_data.dart';
import 'package:flutter/material.dart';

import '../text/labels.dart';
import '../widgets/confirmation_dots.dart';
import '../widgets/status_pill.dart';

class AscentRow extends StatelessWidget {
  const AscentRow({
    required this.ascent,
    required this.state,
    required this.wide,
    required this.selected,
    required this.focused,
    required this.onTap,
    required this.onPublish,
    required this.onReject,
  });

  final Ascent ascent;
  final AscentsLoaded state;
  final bool wide;
  final bool selected;
  final bool focused;
  final VoidCallback onTap;
  final VoidCallback onPublish;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final peak = state.peakOf(ascent);
    final decidable = ascent.status is Confirmed;

    final background = selected ? scheme.primaryContainer.withValues(alpha: 0.45) : null;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: background,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 42,
              margin: const EdgeInsets.only(right: 10),
              color: focused ? scheme.primary : Colors.transparent,
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(peak?.name ?? 'Nepoznat vrh', style: theme.textTheme.titleSmall),
                  Text(
                    ascent.title.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (wide) ...[
              Expanded(flex: 2, child: Text(authorName(ascent.authorId), style: theme.textTheme.bodyMedium)),
              SizedBox(
                width: 70,
                child: Text(formatNumber(ascent.distanceKm), textAlign: TextAlign.right),
              ),
              SizedBox(width: 80, child: Text('${ascent.climbM} m', textAlign: TextAlign.right)),
              SizedBox(width: 90, child: ConfirmationDots(count: confirmationCount(ascent.status))),
              SizedBox(width: 110, child: StatusPill(status: ascent.status)),
              SizedBox(
                width: 200,
                child: decidable
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(onPressed: onPublish, child: const Text('Objavi')),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: onReject, child: const Text('Odbij')),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
            ] else ...[
              StatusPill(status: ascent.status),
            ],
          ],
        ),
      ),
    );
  }
}
