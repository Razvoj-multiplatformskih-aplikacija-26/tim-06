import 'dart:math';

import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'seed_data.dart';

final class FakeWeather implements WeatherService {
  const FakeWeather();

  @override
  Future<PeakWeather?> forecast(PeakId peakId) async {
    for (final peak in seedPeaks) {
      if (peak.id != peakId) continue;
      final now = DateTime.now().toUtc();
      final random = Random(peakId.value.hashCode ^ now.day);
      final temperature = (16 + random.nextInt(10)) - peak.altitudeM * 0.0065;
      return PeakWeather(
        peakId: peakId,
        temperatureC: double.parse(temperature.toStringAsFixed(1)),
        windKph: double.parse((8 + random.nextInt(40) + peak.altitudeM / 100).toStringAsFixed(1)),
        summary: const ['Vedro', 'Delimicno oblacno', 'Oblacno', 'Moguca kisa posle podne'][random.nextInt(4)],
        observedAt: now,
      );
    }
    return null;
  }
}
