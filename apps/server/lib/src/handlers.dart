import 'dart:math';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:relic/relic.dart' hide Result;
import 'package:use_cases/use_cases.dart';

import 'http.dart';
import 'postgres_ascents.dart';
import 'sessions.dart';

final class AscentHandlers {
  AscentHandlers({required this.ascents, required this.weather, required Clock clock})
      : _clock = clock,
        _create = CreateAscentUseCase(ascents: ascents, clock: clock),
        _submit = SubmitAscent(ascents: ascents),
        _confirm = ConfirmAscent(ascents: ascents, clock: clock),
        _publish = PublishAscent(ascents: ascents, clock: clock),
        _reject = RejectAscent(ascents: ascents, clock: clock),
        _archive = ArchiveAscent(ascents: ascents, clock: clock);

  final PostgresAscents ascents;
  final WeatherService weather;
  final Clock _clock;
  final CreateAscentUseCase _create;
  final SubmitAscent _submit;
  final ConfirmAscent _confirm;
  final PublishAscent _publish;
  final RejectAscent _reject;
  final ArchiveAscent _archive;

  Future<Response> catalog(Request request) async {
    final mountains = await ascents.loadMountains();
    final peaks = await ascents.loadPeaks();
    final users = await ascents.loadUsers();
    return json(
      200,
      CatalogDto(
        mountains: [for (final mountain in mountains) mountain.toDto()],
        peaks: [for (final peak in peaks) peak.toDto()],
        users: [for (final user in users) user.toDto()],
      ).toJson(),
    );
  }

  Future<Response> list(Request request) async {
    final actor = currentSession[request]?.user;
    final all = await ascents.loadAscents();
    final visible = [
      for (final ascent in all)
        if (actor == null ? ascent.isPublic : AccessPolicy.canView(actor, ascent)) ascent,
    ];
    return json(200, [for (final ascent in visible) ascent.toDto().toJson()]);
  }

  Future<Response> find(Request request) async {
    final actor = currentSession[request]?.user;
    final ascent = await ascents.find(AscentId(_id(request)));
    if (ascent == null) return problem(const NotFound());
    final visible = actor == null ? ascent.isPublic : AccessPolicy.canView(actor, ascent);
    if (!visible) return problem(const NotFound());
    return json(200, ascent.toDto().toJson());
  }

  Future<Response> create(Request request) async {
    final actor = _actor(request);
    final body = NewAscentDto.fromJson(await readObject(request));
    final created = await _create(
      id: AscentId(_newAscentId()),
      peakId: PeakId(body.peakId),
      author: actor,
      title: body.title,
      difficulty: difficultyFromJson(body.difficulty),
      distanceKm: body.distanceKm,
      waypoints: [for (final waypoint in body.waypoints) waypoint.toDomain()],
      description: body.description,
      track: [for (final point in body.track) point.toDomain()],
    );
    return respond(created, status: 201);
  }

  Future<Response> submit(Request request) => _change(request, (id, actor) => _submit(id: id, by: actor));

  Future<Response> confirm(Request request) => _change(request, (id, actor) => _confirm(id: id, by: actor));

  Future<Response> publish(Request request) => _change(request, (id, actor) => _publish(id: id, by: actor));

  Future<Response> archive(Request request) => _change(request, (id, actor) => _archive(id: id, by: actor));

  Future<Response> reject(Request request) => _change(request, (id, actor) async {
    final body = RejectionDto.fromJson(await readObject(request));
    return _reject(id: id, by: actor, reason: body.reason);
  });

  Future<Response> weatherOf(Request request) async {
    final forecast = await weather.forecast(PeakId(_id(request)));
    if (forecast == null) return problem(const NotFound());
    return json(
      200,
      WeatherDto(
        peakId: forecast.peakId.value,
        temperatureC: forecast.temperatureC,
        windKph: forecast.windKph,
        summary: forecast.summary,
        observedAt: forecast.observedAt,
      ).toJson(),
    );
  }

  Future<Response> _change(Request request, Future<Result<Ascent>> Function(AscentId id, User actor) change) async =>
      respond(await change(AscentId(_id(request)), _actor(request)));

  User _actor(Request request) => currentSession.get(request).user;

  String _id(Request request) => request.rawPathParameters[#id]!;

  String _newAscentId() {
    final random = Random.secure();
    final bytes = [for (var i = 0; i < 8; i++) random.nextInt(256).toRadixString(16).padLeft(2, '0')];
    return 'a-${_clock.now().millisecondsSinceEpoch.toRadixString(16)}${bytes.join()}';
  }
}
