import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../text/labels.dart';
import '../widgets/difficulty_pill.dart';
import '../widgets/peak_summit_art.dart';
import '../dependencies.dart';

class AscentsTab extends StatefulWidget {
  const AscentsTab({super.key});

  @override
  State<AscentsTab> createState() => _AscentsTabState();
}

class _AscentsTabState extends State<AscentsTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staze'),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Jos',
            onSelected: (value) {
              if (value == 'fail') {
                final fake = context.read<MobileDependencies>().fakeRepository;
                if (fake != null) fake.failNextRequest = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sledeci zahtev ce puci, za demonstraciju greske.')),
                );
              }
              if (value == 'reload') {
                context.read<AscentsBloc>().add(const AscentsRequested());
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'reload', child: Text('Ucitaj ponovo')),
              PopupMenuItem(value: 'fail', child: Text('Izazovi gresku na sledecem zahtevu')),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AscentsBloc, AscentsState>(
        builder: (context, state) {
          return switch (state) {
            AscentsLoading() => const Center(child: CircularProgressIndicator()),
            AscentsFailure() => _Message(
              icon: Icons.cloud_off,
              title: 'Staze se nisu ucitale.',
              action: FilledButton(
                onPressed: () => context.read<AscentsBloc>().add(const AscentsRequested()),
                child: const Text('Pokusaj ponovo'),
              ),
            ),
            AscentsEmpty() => const _Message(icon: Icons.terrain, title: 'Jos nema nijedne staze.'),
            AscentsLoaded() => _Loaded(state: state, query: _query, searchController: _searchController, onQuery: (v) => setState(() => _query = v)),
          };
        },
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state, required this.query, required this.searchController, required this.onQuery});

  final AscentsLoaded state;
  final String query;
  final TextEditingController searchController;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final published = state.ascents.where((a) => a.status is Published).where((a) {
      if (q.isEmpty) return true;
      final peak = state.peakOf(a);
      return ('${peak?.name ?? ''} ${a.title.text}').toLowerCase().contains(q);
    }).toList()..sort((a, b) {
      final peakA = state.peakOf(a)?.altitudeM ?? 0;
      final peakB = state.peakOf(b)?.altitudeM ?? 0;
      return peakB.compareTo(peakA);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: searchController,
            onChanged: onQuery,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Trazi vrh ili planinu'),
          ),
        ),
        Expanded(
          child: published.isEmpty
              ? const _Message(icon: Icons.filter_alt_off_outlined, title: 'Nema staza za ovu pretragu.')
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: published.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final ascent = published[index];
              final peak = state.peakOf(ascent);
              final mountain = peak == null ? null : state.mountainOf(peak);
              return _AscentCard(ascent: ascent, peak: peak, mountainName: mountain?.name);
            },
          ),
        ),
      ],
    );
  }
}

class _AscentCard extends StatelessWidget {
  const _AscentCard({required this.ascent, required this.peak, required this.mountainName});

  final Ascent ascent;
  final Peak? peak;
  final String? mountainName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/ascent/${ascent.id.value}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 110,
              child: Stack(
                children: [
                  Positioned.fill(child: PeakSummitArt(altitudeM: peak?.altitudeM ?? 0)),
                  Positioned(
                    right: 12,
                    top: 10,
                    child: Text(
                      '${peak?.altitudeM ?? '—'}',
                      style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 10,
                    right: 12,
                    child: Text(
                      peak?.name ?? 'Nepoznat vrh',
                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${mountainName ?? ''} · od ${ascent.start.name}', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(kilometers(ascent.distanceKm)),
                      const SizedBox(width: 12),
                      Text('+${ascent.climbM} m'),
                      const SizedBox(width: 12),
                      Text(duration(ascent.estimatedMinutes)),
                      const Spacer(),
                      DifficultyPill(difficulty: ascent.difficulty),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, this.action});

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
