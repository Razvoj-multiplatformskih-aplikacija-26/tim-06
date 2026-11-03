

import 'package:flutter/material.dart';

class PeakSummitArt extends StatelessWidget {
  const PeakSummitArt({super.key, required this.altitudeM, this.referenceM = 2500});

  final int altitudeM;
  final int referenceM;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(painter: _SummitPainter(altitudeM: altitudeM, referenceM: referenceM, color: scheme.primary));
  }
}

class _SummitPainter extends CustomPainter {
  _SummitPainter({required this.altitudeM, required this.referenceM, required this.color});

  final int altitudeM;
  final int referenceM;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final ratio = (altitudeM / referenceM).clamp(0.0, 1.0);
    final topY = size.height * (1 - ratio);
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.58, topY)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SummitPainter oldDelegate) => oldDelegate.altitudeM != altitudeM;
}