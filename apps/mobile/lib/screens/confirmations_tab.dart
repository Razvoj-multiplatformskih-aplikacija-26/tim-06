import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fake_data/fake_data.dart';
import '../text/labels.dart';
import 'package:go_router/go_router.dart';
import '../widgets/confirm_dialog.dart';

class ConfirmationsTab extends StatelessWidget {
  const ConfirmationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Za potvrdu'), centerTitle: false),
      body: BlocBuilder<AscentsBloc, AscentsState>(
        builder: (context, state) {
          if (state is! AscentsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final waiting = state.ascents.where((a) => a.status is Proposed).toList();
          if (waiting.isEmpty) {
            return const Center(child: Text('Nema predloga koji cekaju potvrdu.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: waiting.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final ascent = waiting[index];
              final peak = state.peakOf(ascent);
              final proposed = ascent.status as Proposed;
              final isAuthor = ascent.authorId == currentUser.id;
              final already = proposed.confirmedBy.contains(currentUser.id);

              return Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(peak?.name ?? 'Nepoznat vrh', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${ascent.title.text} · ${kilometers(ascent.distanceKm)} · '
                            '${proposed.confirmedBy.length}/$requiredConfirmations potvrde',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => context.push('/ascent/${ascent.id.value}'),
                            child: const Text('Vidi'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: (isAuthor || already)
                                  ? null
                                  : () async {
                                final ok = await confirmAction(
                                  context,
                                  title: 'Potvrditi stazu?',
                                  text: 'Potvrdu ne mozete da povucete.',
                                  action: 'Potvrdi',
                                );
                                if (!ok || !context.mounted) return;
                                context.read<AscentsBloc>().add(AscentConfirmed(ascent.id));
                              },
                              child: Text(isAuthor ? 'Vasa staza' : (already ? 'Potvrdjeno' : 'Potvrdi')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
