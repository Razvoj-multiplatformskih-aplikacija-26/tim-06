
import 'package:backoffice/screens/status_filter.dart';
import 'package:backoffice/screens/summary_card.dart';
import 'package:flutter/cupertino.dart';

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    required this.waiting,
    required this.proposed,
    required this.published,
    required this.closed,
    required this.filter,
    required this.onFilter,
  });

  final int waiting;
  final int proposed;
  final int published;
  final int closed;
  final StatusFilter filter;
  final ValueChanged<StatusFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    final items = <(StatusFilter, int)>[
      (StatusFilter.waiting, waiting),
      (StatusFilter.proposed, proposed),
      (StatusFilter.published, published),
      (StatusFilter.closed, closed),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          for (final (value, count) in items)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SummaryCard(
                label: value.label,
                count: count,
                selected: filter == value,
                onTap: () => onFilter(value),
              ),
            ),
          SummaryCard(
            label: StatusFilter.all.label,
            count: waiting + proposed + published + closed,
            selected: filter == StatusFilter.all,
            onTap: () => onFilter(StatusFilter.all),
          ),
        ],
      ),
    );
  }
}