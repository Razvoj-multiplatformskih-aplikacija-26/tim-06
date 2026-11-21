import 'json.dart';

final class WeatherDto {
  const WeatherDto({
    required this.peakId,
    required this.temperatureC,
    required this.windKph,
    required this.summary,
    required this.observedAt,
  });

  final String peakId;
  final double temperatureC;
  final double windKph;
  final String summary;
  final DateTime observedAt;

  Map<String, Object?> toJson() => {
    'peakId': peakId,
    'temperatureC': temperatureC,
    'windKph': windKph,
    'summary': summary,
    'observedAt': instantToJson(observedAt),
  };

  factory WeatherDto.fromJson(Map<String, Object?> json) => WeatherDto(
    peakId: jsonString(json, 'peakId'),
    temperatureC: jsonDouble(json, 'temperatureC'),
    windKph: jsonDouble(json, 'windKph'),
    summary: jsonString(json, 'summary'),
    observedAt: jsonInstant(json, 'observedAt'),
  );
}
