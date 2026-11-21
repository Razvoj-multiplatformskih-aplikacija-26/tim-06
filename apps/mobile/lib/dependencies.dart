import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart';
import 'package:fake_data/fake_data.dart';
import 'package:use_cases/use_cases.dart';

/// jedino mesto u mobilnoj aplikaciji koje zna da li podaci dolaze sa servera ili
/// iz liste u memoriji, ekrani i blokovi iznad ovoga ne znaju ni jedno ni drugo
final class AppDependencies {
  AppDependencies({
    required this.clock,
    required this.ascents,
    required this.weather,
    required SessionRepository sessions,
  }) : logIn = LogIn(sessions: sessions),
        restoreSession = RestoreSession(sessions: sessions),
        logOut = LogOut(sessions: sessions),
        sessionExpirations = sessions.expirations;

  factory AppDependencies.server({
    required Uri baseUri,
    required TokenStore tokens,
    Clock clock = const SystemClock(),
  }) {
    final api = ApiClient(baseUri: baseUri, tokens: tokens);
    return AppDependencies(
      clock: clock,
      ascents: HttpAscentRepository(api),
      weather: HttpWeatherService(api),
      sessions: HttpSessionRepository(api),
    );
  }

  /// rad bez servera, za ekrane i za demonstraciju kada baza nije podignuta
  factory AppDependencies.fake({Clock clock = const SystemClock(), Duration delay = const Duration(milliseconds: 400)}) {
    return AppDependencies(
      clock: clock,
      ascents: FakeAscentRepository(delay),
      weather: const FakeWeather(),
      sessions: FakeSessions(signedInAs: currentUser),
    );
  }

  final Clock clock;
  final AscentRepository ascents;
  final WeatherService weather;
  final LogIn logIn;
  final RestoreSession restoreSession;
  final LogOut logOut;
  final Stream<void> sessionExpirations;
}
