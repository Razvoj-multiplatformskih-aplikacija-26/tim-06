

import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:fake_data/fake_data.dart';
import 'package:flutter/material.dart';

import '../text/labels.dart';
import 'elevation_profile.dart';
import 'status_pill.dart';

class AscentDetailPanel extends StatelessWidget {
  const AscentDetailPanel({
    super.key,
    required this.ascent,
    required this.state,
    required this.onPublish,
    required this.onReject,
    required this.onArchive,
  });

  final Ascent? ascent;
  final AscentsLoaded state;
  final VoidCallback onPublish;
  final VoidCallback onReject;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = ascent;
    if (selected == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Izaberite stazu u tabeli.\nStrelice gore i dole kreću se kroz redove.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final peak = state.peakOf(selected);
    final mountain = peak == null ? null : state.mountainOf(peak);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            children: [
              Text(peak?.name ?? 'Nepoznat vrh', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                '${mountain?.name ?? ''} · ${peak?.altitudeM ?? 0} m nv',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: StatusPill(status: selected.status)),
              const SizedBox(height: 16),
              Text(selected.title.text, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              ElevationProfile(waypoints: selected.waypoints),
              const SizedBox(height: 12),
              _Row(label: 'Autor', value: authorName(selected.authorId)),
              _Row(label: 'Dužina', value: kilometers(selected.distanceKm)),
              _Row(label: 'Uspon', value: '${selected.climbM} m'),
              _Row(label: 'Trajanje', value: duration(selected.estimatedMinutes)),
              _Row(label: 'Težina', value: difficultyLabel(selected.difficulty)),
              _Row(label: 'Potvrde', value: confirmationsLabel(confirmationCount(selected.status))),
              const SizedBox(height: 16),
              Text('Tačke na putu', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              for (final waypoint in selected.waypoints)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 56,
                        child: Text(
                          kilometers(waypoint.distanceKm),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ),
                      Expanded(child: Text(waypoint.name, style: theme.textTheme.bodyMedium)),
                      Text(
                        '${waypoint.altitudeM} m',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              if (selected.description != null) ...[
                const SizedBox(height: 16),
                Text('Napomena autora', style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                Text(selected.description!.text, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 16),
              _History(status: selected.status),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _Actions(
            status: selected.status,
            onPublish: onPublish,
            onReject: onReject,
            onArchive: onArchive,
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.status});

  final AscentStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = switch (status) {
      Draft() => ['Priprema, autor je još nije poslao.'],
      Proposed(:final confirmedBy) => ['Poslata na potvrdu.', 'Skupljeno ${confirmationsLabel(confirmedBy.length)}.'],
      Confirmed(:final confirmedBy, :final at) => [
        'Skupljeno ${confirmationsLabel(confirmedBy.length)}.',
        'Čeka odluku moderatora od ${_date(at)}.',
      ],
      Published(:final publishedBy, :final at) => ['Objavio ${authorName(publishedBy)}, ${_date(at)}.'],
      Rejected(:final reason, :final rejectedBy, :final at) => [
        'Odbio ${authorName(rejectedBy)}, ${_date(at)}.',
        'Razlog: $reason',
      ],
      Archived(:final archivedBy, :final at) => ['Arhivirao ${authorName(archivedBy)}, ${_date(at)}.'],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Istorija', style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }

  static String _date(DateTime at) {
    final local = at.toLocal();
    return '${local.day}. ${local.month}. ${local.year}.';
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.status,
    required this.onPublish,
    required this.onReject,
    required this.onArchive,
  });

  final AscentStatus status;
  final VoidCallback onPublish;
  final VoidCallback onReject;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return switch (status) {
      Confirmed() => Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onPublish,
              icon: const Icon(Icons.check),
              label: const Text('Objavi  ·  O'),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onReject,
            icon: const Icon(Icons.close),
            label: const Text('Odbij  ·  D'),
          ),
        ],
      ),
      Published() => OutlinedButton.icon(
        onPressed: onArchive,
        icon: const Icon(Icons.inventory_2_outlined),
        label: const Text('Arhiviraj'),
      ),
      Proposed(:final confirmedBy) => Text(
        'Čeka još ${confirmationsLabel(2 - confirmedBy.length)} planinara. Moderator ne potvrđuje umesto njih.',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      Draft() || Rejected() || Archived() => Text(
        'Za ovo stanje nema radnje.',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    };
  }
}