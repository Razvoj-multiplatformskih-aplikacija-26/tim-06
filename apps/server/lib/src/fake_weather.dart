import 'dart:math';

import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'ascent_store.dart';

final class FakeWeatherService implements WeatherService {
  const FakeWeatherService(this._store, {required this.apiKey, required this.clock});

  final AscentStore _store;
  final String apiKey;
  final Clock clock;

  @override
  Future<PeakWeather?> forecast(PeakId peakId) async {
    if (apiKey.isEmpty) {
      throw StateError('WEATHER_API_KEY nije postavljen. Kopirajte .env.example u .env.');
    }
    final peak = await _store.peak(peakId);
    if (peak == null) return null;

    final now = clock.now();
    final seed = peakId.value.hashCode ^ now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    final atSeaLevel = 14 + random.nextInt(12);
    final temperature = atSeaLevel - peak.altitudeM * 0.0065;
    final wind = 5 + random.nextInt(45) + peak.altitudeM / 100;
    return PeakWeather(
      peakId: peakId,
      temperatureC: double.parse(temperature.toStringAsFixed(1)),
      windKph: double.parse(wind.toStringAsFixed(1)),
      summary: _summary(temperature, wind, random),
      observedAt: now,
    );
  }

  String _summary(double temperature, double wind, Random random) {
    if (temperature < 0 && wind > 40) return 'Mraz i jak vetar, greben nije za danas.';
    if (temperature < 0) return 'Ispod nule, racunajte na led na stenama.';
    if (wind > 45) return 'Jak vetar na grebenu.';
    return const ['Vedro', 'Delimicno oblacno', 'Oblacno', 'Moguca kisa posle podne'][random.nextInt(4)];
  }
}