import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fake_data/fake_data.dart';
import '../text/labels.dart';
import '../widgets/status_pill.dart';
import 'package:go_router/go_router.dart';
import '../widgets/confirm_dialog.dart';

class MyAscentsTab extends StatelessWidget {
  const MyAscentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moje staze'), centerTitle: false),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/new-ascent'),
        icon: const Icon(Icons.add),
        label: const Text('Nova staza'),
      ),
      body: BlocBuilder<AscentsBloc, AscentsState>(
        builder: (context, state) {
          if (state is! AscentsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final mine = state.ascents.where((a) => a.authorId == currentUser.id).toList();
          if (mine.isEmpty) {
            return const Center(child: Text('Niste upisali nijednu stazu.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: mine.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final ascent = mine[index];
              final peak = state.peakOf(ascent);
              final missing = requiredConfirmations - confirmationCount(ascent.status);
              final caption = switch (ascent.status) {
                Draft() => 'Priprema na uredjaju, jos nije poslata.',
                Proposed() => 'Nedostaje jos $missing ${plural(missing, "potvrda", "potvrde", "potvrda")}.',
                Confirmed() => 'Ima sve potvrde, ceka moderatora.',
                Published() => 'Objavljena u katalogu.',
                Rejected(:final reason) => 'Odbijena: $reason',
                Archived() => 'Povucena.',
              };

              return Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(peak?.name ?? 'Nepoznat vrh', style: Theme.of(context).textTheme.titleMedium),
                          ),
                          StatusPill(status: ascent.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(caption, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (ascent.status is Draft)
                            FilledButton(
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
                              child: const Text('Posalji'),
                            ),
                          if (ascent.status is Draft || ascent.status is Proposed) ...[
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () async {
                                final ok = await confirmAction(
                                  context,
                                  title: 'Povuci stazu?',
                                  text: '${ascent.title.text} se povlaci i vise ne ide na potvrdu.',
                                  action: 'Povuci',
                                );
                                if (!ok || !context.mounted) return;
                                context.read<AscentsBloc>().add(AscentArchived(ascent.id));
                              },
                              child: const Text('Povuci'),
                            ),
                          ],
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/ascent/${ascent.id.value}'),
                            child: const Text('Vidi'),
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
