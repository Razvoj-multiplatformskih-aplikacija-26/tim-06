
import 'package:flutter/material.dart';

class ConfirmationDots extends StatelessWidget {
  const ConfirmationDots({super.key, required this.count, this.required_ = requiredConfirmationsForUi});

  static const requiredConfirmationsForUi = 2;

  final int count;
  final int required_;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < required_; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < count ? scheme.primary : Colors.transparent,
                border: Border.all(color: i < count ? scheme.primary : scheme.outlineVariant, width: 2),
              ),
            ),
          ),
        const SizedBox(width: 4),
        Text('$count/$required_', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
