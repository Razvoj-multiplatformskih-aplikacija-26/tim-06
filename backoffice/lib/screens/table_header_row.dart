
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TableHeaderRow extends StatelessWidget {
  const TableHeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('VRH I USPON', style: style)),
          Expanded(flex: 2, child: Text('AUTOR', style: style)),
          SizedBox(width: 70, child: Text('KM', style: style, textAlign: TextAlign.right)),
          SizedBox(width: 80, child: Text('USPON', style: style, textAlign: TextAlign.right)),
          SizedBox(width: 90, child: Text('POTVRDE', style: style)),
          SizedBox(width: 110, child: Text('STANJE', style: style)),
          const SizedBox(width: 180),
        ],
      ),
    );
  }
}