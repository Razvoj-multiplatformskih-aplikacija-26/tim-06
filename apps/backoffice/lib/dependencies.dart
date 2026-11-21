import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart';
import 'package:fake_data/fake_data.dart';
import 'package:use_cases/use_cases.dart';

/// jedino mesto u backoffice-u koje zna odakle podaci dolaze
final class BackofficeDependencies {
  BackofficeDependencies({
    required this.clock,
    required this.ascents,
    required this.weather,
    required SessionRepository sessions,
  }) : logIn = LogIn(sessions: sessions),
        restoreSession = RestoreSession(sessions: sessions),
        logOut = LogOut(sessions: sessions),
        sessionExpirations = sessions.expirations;

  factory BackofficeDependencies.server({
    required Uri baseUri,
    required TokenStore tokens,
    Clock clock = const SystemClock(),
  }) {
    final api = ApiClient(baseUri: baseUri, tokens: tokens);
    return BackofficeDependencies(
      clock: clock,
      ascents: HttpAscentRepository(api),
      weather: HttpWeatherService(api),
      sessions: HttpSessionRepository(api),
    );
  }

  factory BackofficeDependencies.fake({
    Clock clock = const SystemClock(),
    Duration delay = const Duration(milliseconds: 400),
  }) {
    return BackofficeDependencies(
      clock: clock,
      ascents: FakeAscentRepository(delay),
      weather: const FakeWeather(),
      sessions: FakeSessions(signedInAs: moderator),
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
