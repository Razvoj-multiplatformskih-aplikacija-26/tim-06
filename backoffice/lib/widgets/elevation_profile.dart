
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

class ElevationProfile extends StatelessWidget {
  const ElevationProfile({super.key, required this.waypoints, this.height = 90});

  final List<Waypoint> waypoints;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _ProfilePainter(waypoints: waypoints, color: scheme.primary)),
    );
  }
}

class _ProfilePainter extends CustomPainter {
  _ProfilePainter({required this.waypoints, required this.color});

  final List<Waypoint> waypoints;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (waypoints.length < 2) return;

    final maxKm = waypoints.last.distanceKm == 0 ? 1.0 : waypoints.last.distanceKm;
    var lowest = waypoints.first.altitudeM;
    var highest = waypoints.first.altitudeM;
    for (final point in waypoints) {
      if (point.altitudeM < lowest) lowest = point.altitudeM;
      if (point.altitudeM > highest) highest = point.altitudeM;
    }
    final span = (highest - lowest) < 100 ? 100.0 : (highest - lowest).toDouble();

    Offset at(Waypoint point) {
      final x = point.distanceKm / maxKm * size.width;
      final y = size.height - 10 - (point.altitudeM - lowest) / span * (size.height - 20);
      return Offset(x, y);
    }

    final line = Path()..moveTo(at(waypoints.first).dx, at(waypoints.first).dy);
    for (final point in waypoints.skip(1)) {
      final offset = at(point);
      line.lineTo(offset.dx, offset.dy);
    }

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.18));
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round,
    );
    for (final point in waypoints) {
      canvas.drawCircle(at(point), 3.4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_ProfilePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.waypoints != waypoints;
}