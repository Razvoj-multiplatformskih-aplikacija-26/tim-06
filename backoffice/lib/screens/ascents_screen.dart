
import 'package:backoffice/screens/status_filter.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:fake_data/fake_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../dependencies.dart';
import '../text/domain_errors.dart';
import 'loaded_view.dart';
import 'message_view.dart';

class AscentsScreen extends StatefulWidget {
  const AscentsScreen({super.key, this.initialSelectedId});

  final AscentId? initialSelectedId;

  @override
  State<AscentsScreen> createState() => _AscentsScreenState();
}

class _AscentsScreenState extends State<AscentsScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode(debugLabel: 'tabela');

  StatusFilter _filter = StatusFilter.waiting;
  String _query = '';
  AscentId? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialSelectedId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _select(AscentId? id) {
    setState(() => _selectedId = id);
    context.go(id == null ? '/' : '/?ascent=${id.value}');
  }

  List<Ascent> _visible(AscentsLoaded state) {
    final query = _query.trim().toLowerCase();
    final list = state.ascents.where((ascent) {
      if (!_filter.matches(ascent.status)) return false;
      if (query.isEmpty) return true;
      final peak = state.peakOf(ascent);
      final haystack = '${peak?.name ?? ''} ${ascent.title.text} ${authorName(ascent.authorId)}'.toLowerCase();
      return haystack.contains(query);
    }).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Ascent? _selected(AscentsLoaded state) {
    for (final ascent in state.ascents) {
      if (ascent.id == _selectedId) return ascent;
    }
    return null;
  }

  void _move(int delta, List<Ascent> list) {
    if (list.isEmpty) return;
    var index = list.indexWhere((ascent) => ascent.id == _selectedId);
    index = index < 0 ? 0 : (index + delta).clamp(0, list.length - 1);
    _select(list[index].id);
  }

  void _publish(Ascent ascent) {
    context.read<AscentsBloc>().add(AscentPublished(ascent.id));
  }

  Future<void> _reject(Ascent ascent) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odbiti stazu?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${ascent.title.text}. Autor vidi razlog.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Razlog koji vidi autor'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Odustani')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Odbij'),
          ),
        ],
      ),
    );
    if (reason == null || !mounted) return;
    context.read<AscentsBloc>().add(AscentRejected(ascent.id, reason));
  }

  Future<void> _archive(Ascent ascent) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arhivirati stazu?'),
        content: Text('${ascent.title.text} nestaje iz javnog kataloga.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Odustani')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Arhiviraj')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.read<AscentsBloc>().add(AscentArchived(ascent.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AscentsBloc, AscentsState>(
      listenWhen: (previous, current) =>
      current is AscentsLoaded && current.lastError != null && previous != current,
      listener: (context, state) {
        if (state is! AscentsLoaded) return;
        final error = state.lastError;
        if (error == null) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(messageFor(error))));
        context.read<AscentsBloc>().add(const AscentErrorCleared());
      },
      builder: (context, state) {
        final fakeRepository = context.read<BackofficeDependencies>().fakeRepository;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Staze · backoffice'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Text(
                    'Moderator',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Još',
                onSelected: (value) {
                  if (value == 'fail') {
                    if (fakeRepository != null) fakeRepository.failNextRequest = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sledeći zahtev će pući, za demonstraciju greške.')),
                    );
                  }
                  if (value == 'reload') {
                    context.read<AscentsBloc>().add(const AscentsRequested());
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'reload', child: Text('Učitaj ponovo')),
                  PopupMenuItem(value: 'fail', child: Text('Izazovi grešku na sledećem zahtevu')),
                ],
              ),
            ],
          ),
          body: switch (state) {
            AscentsLoading() => const Center(child: CircularProgressIndicator()),
            AscentsFailure() => MessageView(
              icon: Icons.cloud_off,
              title: 'Podaci se nisu učitali.',
              action: FilledButton(
                onPressed: () => context.read<AscentsBloc>().add(const AscentsRequested()),
                child: const Text('Pokušaj ponovo'),
              ),
            ),
            AscentsEmpty() => const MessageView(icon: Icons.inbox_outlined, title: 'Još nema nijedne staze.'),
            AscentsLoaded() => LoadedView(
              state: state,
              list: _visible(state),
              selected: _selected(state),
              filter: _filter,
              searchController: _searchController,
              focusNode: _focusNode,
              onFilter: (value) => setState(() => _filter = value),
              onQuery: (value) => setState(() => _query = value),
              onSelect: (ascent) => _select(ascent.id),
              onClose: () => _select(null),
              onMove: _move,
              onPublish: _publish,
              onReject: _reject,
              onArchive: _archive,
            ),
          },
        );
      },
    );
  }
}