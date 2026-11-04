import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fake_data/fake_data.dart';
import '../text/labels.dart';
import '../widgets/difficulty_pill.dart';
import '../widgets/elevation_profile.dart';
import '../widgets/peak_summit_art.dart';
import '../widgets/status_pill.dart';
import '../widgets/confirm_dialog.dart';

class AscentDetailScreen extends StatelessWidget {
  const AscentDetailScreen({super.key, required this.ascentId});

  final AscentId ascentId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AscentsBloc, AscentsState>(
      builder: (context, state) {
        if (state is! AscentsLoaded) return const Scaffold(body: SizedBox.shrink());

        Ascent? ascent;
        for (final a in state.ascents) {
          if (a.id == ascentId) ascent = a;
        }
        if (ascent == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Staza vise ne postoji.')));
        }

        final peak = state.peakOf(ascent);
        final mountain = peak == null ? null : state.mountainOf(peak);
        final theme = Theme.of(context);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PeakSummitArt(altitudeM: peak?.altitudeM ?? 0),
                      Positioned(
                        right: 16,
                        top: 60,
                        child: Text(
                          '${peak?.altitudeM ?? '—'}',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Text(
                          peak?.name ?? 'Nepoznat vrh',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.list(
                  children: [
                    Text(mountain?.name ?? '', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        StatusPill(status: ascent.status),
                        DifficultyPill(difficulty: ascent.difficulty),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(ascent.title.text, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Stat(label: 'duzina', value: kilometers(ascent.distanceKm)),
                        _Stat(label: 'uspon', value: '${ascent.climbM} m'),
                        _Stat(label: 'hoda', value: duration(ascent.estimatedMinutes)),
                        _Stat(label: 'potvrde', value: '${confirmationCount(ascent.status)}/2'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Visinski profil', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    ElevationProfile(waypoints: ascent.waypoints),
                    const SizedBox(height: 20),
                    Text('Tacke na putu', style: theme.textTheme.labelLarge),
                    for (final wp in ascent.waypoints)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 58,
                              child: Text(
                                kilometers(wp.distanceKm),
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(wp.name, style: theme.textTheme.bodyMedium),
                                  if (wp.note != null)
                                    Text(
                                      wp.note!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text('${wp.altitudeM} m', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    if (ascent.description != null) ...[
                      const SizedBox(height: 16),
                      Text('Napomena autora', style: theme.textTheme.labelLarge),
                      const SizedBox(height: 6),
                      Text(ascent.description!.text),
                    ],
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _Actions(ascent: ascent),
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.ascent});

  final Ascent ascent;

  @override
  Widget build(BuildContext context) {
    final isAuthor = ascent.authorId == currentUser.id;

    if (ascent.status is Published) {
      return FilledButton.icon(
        onPressed: () => context.push('/ascent/${ascent.id.value}/route'),
        icon: const Icon(Icons.hiking),
        label: const Text('Startuj rutu'),
      );
    }
    if (ascent.status is Draft && isAuthor) {
      return FilledButton(
        onPressed: () async {
          final ok = await confirmAction(
            context,
            title: 'Poslati stazu na potvrdu?',
            text: '${ascent.title.text} postaje vidljiva drugim planinarima.',
            action: 'Posalji',
          );
          if (!ok || !context.mounted) return;
          context.read<AscentsBloc>().add(AscentSubmitted(ascent.id));
        },
        child: const Text('Posalji na potvrdu'),
      );
    }
    if (ascent.status is Proposed && !isAuthor) {
      final already = (ascent.status as Proposed).confirmedBy.contains(currentUser.id);
      return FilledButton(
        onPressed: already ? null : () async {
          final ok = await confirmAction(
            context,
            title: 'Potvrditi stazu?',
            text: 'Potvrdu ne mozete da povucete.',
            action: 'Potvrdi',
          );
          if (!ok || !context.mounted) return;
          context.read<AscentsBloc>().add(AscentConfirmed(ascent.id));
        },
        child: Text(already ? 'Vec potvrdjeno' : 'Potvrdi stazu'),
      );
    }
    return const SizedBox.shrink();
  }
}
