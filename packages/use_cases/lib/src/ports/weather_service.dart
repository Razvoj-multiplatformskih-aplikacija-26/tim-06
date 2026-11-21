import 'package:domain/domain.dart';

abstract interface class WeatherService {
  Future<PeakWeather?> forecast(PeakId peakId);
}

final class PeakWeather {
  const PeakWeather({
    required this.peakId,
    required this.temperatureC,
    required this.windKph,
    required this.summary,
    required this.observedAt,
  });

  final PeakId peakId;
  final double temperatureC;
  final double windKph;
  final String summary;
  final DateTime observedAt;
}