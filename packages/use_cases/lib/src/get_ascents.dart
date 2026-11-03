
import 'package:domain/domain.dart';

import '../use_cases.dart';

final class AscentsOverview {
  const AscentsOverview({required this.ascents, required this.peaks, required this.mountains});

  final List<Ascent> ascents;
  final List<Peak> peaks;
  final List<Mountain> mountains;
}

final class GetAscents {
  const GetAscents({required this.ascents});

  final AscentRepository ascents;

  Future<AscentsOverview> call() async {
    final mountains = await ascents.loadMountains();
    final peaks = await ascents.loadPeaks();
    final items = await ascents.loadAscents();
    return AscentsOverview(ascents: items, peaks: peaks, mountains: mountains);
  }
}