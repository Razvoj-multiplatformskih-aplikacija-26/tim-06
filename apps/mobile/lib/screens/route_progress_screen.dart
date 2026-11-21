import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../text/labels.dart';

class RouteProgressScreen extends StatefulWidget {
  const RouteProgressScreen({super.key, required this.ascentId});

  final AscentId ascentId;

  @override
  State<RouteProgressScreen> createState() => _RouteProgressScreenState();
}

class _RouteProgressScreenState extends State<RouteProgressScreen> {
  final _reached = <int>{0};
  late final DateTime _startedAt;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Ascent? _ascent;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = DateTime.now().difference(_startedAt));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _nextIndex {
    for (var i = 0; i < _ascent!.waypoints.length; i++) {
      if (!_reached.contains(i)) return i;
    }
    return _ascent!.waypoints.length - 1;
  }

  bool get _finished => _reached.length == _ascent!.waypoints.length;

  String get _clock {
    final minutes = _elapsed.inMinutes;
    final seconds = _elapsed.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AscentsBloc>().state;
    _ascent = null;
    if (state is AscentsLoaded) {
      for (final a in state.ascents) {
        if (a.id == widget.ascentId) _ascent = a;
      }
    }
    if (_ascent == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Staza vise ne postoji.')));
    }
    final theme = Theme.of(context);
    final waypoints = _ascent!.waypoints;
    final doneKm = _reached.isEmpty ? 0.0 : waypoints[_reached.reduce((a, b) => a > b ? a : b)].distanceKm;
    final progress = _reached.length / waypoints.length;

    return Scaffold(
      appBar: AppBar(title: Text(_ascent!.title.text)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Live(value: _clock, label: 'vreme'),
                  _Live(value: formatNumber(doneKm), label: 'km od ${formatNumber(_ascent!.distanceKm)}'),
                  _Live(value: '${(progress * 100).round()}%', label: 'predjeno'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: progress, minHeight: 8),
          ),
          const SizedBox(height: 20),
          Text('Tacke na putu', style: theme.textTheme.labelLarge),
          for (var i = 0; i < waypoints.length; i++)
            CheckboxListTile(
              value: _reached.contains(i),
              onChanged: (checked) => setState(() {
                if (checked ?? false) {
                  _reached.add(i);
                } else {
                  _reached.remove(i);
                }
              }),
              title: Text(
                waypoints[i].name,
                style: _reached.contains(i)
                    ? TextStyle(decoration: TextDecoration.lineThrough, color: theme.colorScheme.onSurfaceVariant)
                    : null,
              ),
              subtitle: Text('${formatNumber(waypoints[i].distanceKm)} km · ${waypoints[i].altitudeM} m'),
              tileColor: (!_reached.contains(i) && i == _nextIndex) ? theme.colorScheme.primaryContainer : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text('Stikliranje radi bez signala. GPS pracenje dolazi u KT3.'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _finished
              ? FilledButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.flag),
            label: const Text('Zavrsi uspon'),
          )
              : FilledButton(
            onPressed: () => setState(() => _reached.add(_nextIndex)),
            child: Text('Stigao sam: ${waypoints[_nextIndex].name}'),
          ),
        ),
      ),
    );
  }
}

class _Live extends StatelessWidget {
  const _Live({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
