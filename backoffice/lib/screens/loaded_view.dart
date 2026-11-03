

import 'package:backoffice/screens/status_filter.dart';
import 'package:backoffice/screens/summary_row.dart';
import 'package:backoffice/screens/table_header_row.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/ascent_detail_panel.dart';
import 'ascent_row.dart';
import 'layout.dart';
import 'message_view.dart';

class LoadedView extends StatelessWidget {
  const LoadedView({
    required this.state,
    required this.list,
    required this.selected,
    required this.filter,
    required this.searchController,
    required this.focusNode,
    required this.onFilter,
    required this.onQuery,
    required this.onSelect,
    required this.onClose,
    required this.onMove,
    required this.onPublish,
    required this.onReject,
    required this.onArchive,
  });

  final AscentsLoaded state;
  final List<Ascent> list;
  final Ascent? selected;
  final StatusFilter filter;
  final TextEditingController searchController;
  final FocusNode focusNode;
  final ValueChanged<StatusFilter> onFilter;
  final ValueChanged<String> onQuery;
  final ValueChanged<Ascent> onSelect;
  final VoidCallback onClose;
  final void Function(int delta, List<Ascent> list) onMove;
  final ValueChanged<Ascent> onPublish;
  final ValueChanged<Ascent> onReject;
  final ValueChanged<Ascent> onArchive;

  int _count(bool Function(AscentStatus status) test) =>
      state.ascents.where((ascent) => test(ascent.status)).length;

  void _actOnSelected(void Function(Ascent ascent) action) {
    final ascent = selected;
    if (ascent != null) action(ascent);
  }

  @override
  Widget build(BuildContext context) {
    final current = selected;

    final table = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => onMove(1, list),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => onMove(-1, list),
        const SingleActivator(LogicalKeyboardKey.keyO): () => _actOnSelected((ascent) {
          if (ascent.status is Confirmed) onPublish(ascent);
        }),
        const SingleActivator(LogicalKeyboardKey.keyD): () => _actOnSelected((ascent) {
          if (ascent.status is Confirmed) onReject(ascent);
        }),
      },
      child: Focus(
        focusNode: focusNode,
        autofocus: true,
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SummaryRow(
                  waiting: _count((status) => status is Confirmed),
                  proposed: _count((status) => status is Proposed),
                  published: _count((status) => status is Published),
                  closed: _count((status) => status is Rejected || status is Archived),
                  filter: filter,
                  onFilter: onFilter,
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: searchController,
                    onChanged: onQuery,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Traži po vrhu, autoru ili nazivu',
                    ),
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? const MessageView(icon: Icons.filter_alt_off_outlined, title: 'Nema staza za ovaj filter.')
                      : LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 560;
                      return ListView.separated(
                        itemCount: list.length + (wide ? 1 : 0),
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          if (wide && index == 0) return const TableHeaderRow();
                          final ascent = list[wide ? index - 1 : index];
                          final isSelected = ascent.id == current?.id;
                          return AscentRow(
                            ascent: ascent,
                            state: state,
                            wide: wide,
                            selected: isSelected,
                            focused: isSelected && hasFocus,
                            onTap: () {
                              onSelect(ascent);
                              focusNode.requestFocus();
                            },
                            onPublish: () => onPublish(ascent),
                            onReject: () => onReject(ascent),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Tastatura:  ↑ ↓ kroz redove  ·  O objavi  ·  D odbij',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= wideBreakpoint) {
          return Row(
            children: [
              Expanded(child: table),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 360,
                child: AscentDetailPanel(
                  ascent: current,
                  state: state,
                  onPublish: () => _actOnSelected(onPublish),
                  onReject: () => _actOnSelected(onReject),
                  onArchive: () => _actOnSelected(onArchive),
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            table,
            if (current != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  elevation: 8,
                  color: Theme.of(context).colorScheme.surface,
                  child: SizedBox(
                    height: constraints.maxHeight * 0.65,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(current.title.text),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: onClose,
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: AscentDetailPanel(
                            ascent: current,
                            state: state,
                            onPublish: () => onPublish(current),
                            onReject: () => onReject(current),
                            onArchive: () => onArchive(current),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}