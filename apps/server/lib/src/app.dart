import 'package:api_contract/api_contract.dart';
import 'package:relic/relic.dart';

import 'cors.dart';
import 'handlers.dart';
import 'http.dart';
import 'sessions.dart';

Handler buildHandler(AscentHandlers ascents, SessionHandlers sessions, {required List<String> corsOrigins}) {
  final signedIn = sessions.signedIn;
  final maybe = sessions.optionallySignedIn;
  final router = RelicRouter()
    ..get(ApiPaths.health, (request) => Response.ok(body: Body.fromString('ok')))
    ..get(ApiPaths.catalog, ascents.catalog)
    ..get(ApiPaths.ascents, maybe(ascents.list))
    ..get(ApiPaths.ascent(':id'), maybe(ascents.find))
    ..post(ApiPaths.ascents, signedIn(ascents.create))
    ..post(ApiPaths.submission(':id'), signedIn(ascents.submit))
    ..post(ApiPaths.confirmation(':id'), signedIn(ascents.confirm))
    ..post(ApiPaths.publication(':id'), signedIn(ascents.publish))
    ..post(ApiPaths.rejection(':id'), signedIn(ascents.reject))
    ..post(ApiPaths.archival(':id'), signedIn(ascents.archive))
    ..get(ApiPaths.weather(':id'), ascents.weatherOf)
    ..post(ApiPaths.sessions, sessions.logIn)
    ..get(ApiPaths.currentSession, signedIn(sessions.current))
    ..delete(ApiPaths.currentSession, signedIn(sessions.logOut))
    ..fallback = respondWith((request) => problemResponse(notFoundRoute));
  return const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(allowOrigins(corsOrigins))
      .addMiddleware(handleErrors())
      .addHandler(router.asHandler);
}
