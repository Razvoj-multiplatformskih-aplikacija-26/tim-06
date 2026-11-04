import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../text/domain_errors.dart';
import '../text/labels.dart';

class NewAscentScreen extends StatefulWidget {
  const NewAscentScreen({super.key});

  @override
  State<NewAscentScreen> createState() => _NewAscentScreenState();
}

class _NewAscentScreenState extends State<NewAscentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startNameController = TextEditingController();
  final _startAltitudeController = TextEditingController();
  final _distanceController = TextEditingController(text: '10');

  PeakId? _peakId;
  Difficulty _difficulty = Difficulty.moderate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startNameController.dispose();
    _startAltitudeController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final error = AscentTitle.parse(value ?? '').errorOrNull;
    return error == null ? null : messageFor(error);
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) return null;
    final error = AscentDescription.parse(value).errorOrNull;
    return error == null ? null : messageFor(error);
  }

  String? _validateDistance(String? value) {
    final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
    if (parsed == null) return 'Unesite broj.';
    if (!AscentLimits.isValidDistance(parsed)) return messageFor(InvalidDistance(parsed));
    return null;
  }

  String? _validateStartAltitude(String? value, Peak? peak) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null) return 'Unesite visinu polaska.';
    if (peak != null && parsed >= peak.altitudeM) {
      return messageFor(StartNotBelowSummit(parsed, peak.altitudeM));
    }
    return null;
  }

  void _save({required bool submitImmediately}) {
    if (_peakId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izaberite vrh.')));
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final state = context.read<AscentsBloc>().state;
    if (state is! AscentsLoaded) return;

    Peak? peak;
    for (final p in state.peaks) {
      if (p.id == _peakId) peak = p;
    }
    if (peak == null) return;

    final distance = double.parse(_distanceController.text.replaceAll(',', '.'));
    final startAltitude = int.parse(_startAltitudeController.text);

    final waypoints = [
      Waypoint(0, startAltitude, _startNameController.text.trim(), 'polazak', null),
      Waypoint(distance, peak.altitudeM, peak.name, 'vrh', null),
    ];

    context.read<AscentsBloc>().add(
      AscentCreated(
        id: AscentId('a-${DateTime.now().millisecondsSinceEpoch}'),
        peakId: peak.id,
        title: _titleController.text,
        difficulty: _difficulty,
        distanceKm: distance,
        waypoints: waypoints,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        submitImmediately: submitImmediately,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AscentsBloc, AscentsState>(
      builder: (context, state) {
        if (state is! AscentsLoaded) return const Scaffold(body: SizedBox.shrink());

        final peaks = [...state.peaks]..sort((a, b) => b.altitudeM.compareTo(a.altitudeM));
        Peak? selected;
        for (final p in peaks) {
          if (p.id == _peakId) selected = p;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Nova staza')),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<PeakId>(
                  initialValue: _peakId,
                  decoration: const InputDecoration(labelText: 'Vrh'),
                  items: [
                    for (final peak in peaks)
                      DropdownMenuItem(value: peak.id, child: Text('${peak.name} · ${peak.altitudeM} m')),
                  ],
                  onChanged: (value) => setState(() => _peakId = value),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Naziv staze'),
                  validator: _validateTitle,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _startNameController,
                  decoration: const InputDecoration(labelText: 'Odakle se krece'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Unesite polaznu tacku.' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _startAltitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Visina polaska (m)'),
                  validator: (value) => _validateStartAltitude(value, selected),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _distanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Duzina (km)'),
                  validator: _validateDistance,
                ),
                const SizedBox(height: 14),
                Text('Tezina', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                SegmentedButton<Difficulty>(
                  segments: [
                    for (final difficulty in Difficulty.values)
                      ButtonSegment(value: difficulty, label: Text(difficultyLabel(difficulty))),
                  ],
                  selected: {_difficulty},
                  onSelectionChanged: (value) => setState(() => _difficulty = value.first),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Opis (voda, markacija, opasni delovi)',
                    alignLabelWithHint: true,
                  ),
                  validator: _validateDescription,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _save(submitImmediately: false),
                        child: const Text('Sacuvaj pripremu'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _save(submitImmediately: true),
                        child: const Text('Posalji'),
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
  }
}
