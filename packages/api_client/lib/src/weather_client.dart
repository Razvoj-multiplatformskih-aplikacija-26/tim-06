import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'api_client.dart';

/// Vreme na vrhu klijent trazi od svog servera, nikada od spoljne usluge.
/// Zato kljuc te usluge ne postoji ni u jednoj isporucenoj aplikaciji.
final class HttpWeatherService implements WeatherService {
  const HttpWeatherService(this._api);

  final ApiClient _api;

  @override
  Future<PeakWeather?> forecast(PeakId peakId) async {
    final answer = await _api.get(ApiPaths.weather(peakId.value));
    if (answer case ApiRejected(error: NotFound())) return null;
    final dto = accepted(answer, (json) => WeatherDto.fromJson(object(json)));
    return PeakWeather(
      peakId: PeakId(dto.peakId),
      temperatureC: dto.temperatureC,
      windKph: dto.windKph,
      summary: dto.summary,
      observedAt: dto.observedAt,
    );
  }
}
