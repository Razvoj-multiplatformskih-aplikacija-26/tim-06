
abstract final class ApiPaths {
  static const health = '/health';
  static const catalog = '/api/v1/catalog';
  static const ascents = '/api/v1/ascents';
  static const sessions = '/api/v1/sessions';
  static const currentSession = '/api/v1/sessions/current';

  static String ascent(String id) => '$ascents/$id';

  static String submission(String id) => '${ascent(id)}/submission';

  static String confirmation(String id) => '${ascent(id)}/confirmation';

  static String publication(String id) => '${ascent(id)}/publication';

  static String rejection(String id) => '${ascent(id)}/rejection';

  static String archival(String id) => '${ascent(id)}/archival';

  static String weather(String peakId) => '/api/v1/peaks/$peakId/weather';
}

abstract final class ApiCookies {
  static const session = 'staze_session';
}
