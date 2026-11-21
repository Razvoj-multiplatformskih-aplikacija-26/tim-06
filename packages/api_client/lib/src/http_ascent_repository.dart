import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'api_client.dart';

/// Isti port koji u KT1 puni lista u memoriji, ovde ispunjen serverom.
/// Zato Bloc i ekrani ne znaju odakle podaci dolaze i nisu se promenili.
final class HttpAscentRepository implements AscentRepository {
  HttpAscentRepository(this._api);

  final ApiClient _api;

  /// Planine, vrhovi i imena menjaju se retko, a ekran ih trazi tri puta za redom.
  /// Zato se jedan poziv pamti; `refresh` ga baca kada treba ponovo.
  Future<CatalogDto>? _catalog;

  void refresh() => _catalog = null;

  Future<CatalogDto> _loadCatalog() async {
    final pending = _catalog ??= _fetchCatalog();
    try {
      return await pending;
    } on Object {
      _catalog = null;
      rethrow;
    }
  }

  Future<CatalogDto> _fetchCatalog() async {
    final answer = await _api.get(ApiPaths.catalog);
    return accepted(answer, (json) => CatalogDto.fromJson(object(json)));
  }

  @override
  Future<List<Mountain>> loadMountains() async => (await _loadCatalog()).mountainsDomain;

  @override
  Future<List<Peak>> loadPeaks() async => (await _loadCatalog()).peaksDomain;

  @override
  Future<List<User>> loadUsers() async => (await _loadCatalog()).usersDomain;

  @override
  Future<List<Ascent>> loadAscents() async {
    final answer = await _api.get(ApiPaths.ascents);
    return accepted(answer, (json) => [for (final item in objects(json)) AscentDto.fromJson(item).toDomain()]);
  }

  @override
  Future<Ascent?> find(AscentId id) async {
    final answer = await _api.get(ApiPaths.ascent(id.value));
    if (answer case ApiRejected(error: NotFound())) return null;
    return accepted(answer, _ascent);
  }

  @override
  Future<Result<Ascent>> add(Ascent ascent) async {
    // Identifikator, autor i pocetno stanje ne idu na mrezu: njih odredjuje server.
    final body = NewAscentDto(
      peakId: ascent.peakId.value,
      title: ascent.title.text,
      description: ascent.description?.text,
      difficulty: ascent.difficulty.name,
      distanceKm: ascent.distanceKm,
      waypoints: [for (final waypoint in ascent.waypoints) waypoint.toDto()],
      track: [for (final point in ascent.track) point.toDto()],
    );
    return resultOf(await _api.post(ApiPaths.ascents, body: body.toJson()), _ascent);
  }

  /// Promena stanja nije upis novog zapisa nego poziv radnje, pa svaka ima svoju
  /// adresu. Server ponovo pokrece isto pravilo nad svojim podacima; telo zahteva
  /// nosi samo ono sto pravilo ne moze da izvede samo, a to je razlog odbijanja.
  @override
  Future<Result<Ascent>> replace(Ascent ascent, {required AscentStatus from}) async {
    final id = ascent.id.value;
    final answer = await switch ((from, ascent.status)) {
      (Draft(), Proposed()) => _api.post(ApiPaths.submission(id)),
      (Proposed(), Proposed() || Confirmed()) => _api.post(ApiPaths.confirmation(id)),
      (_, Published()) => _api.post(ApiPaths.publication(id)),
      (_, Rejected(:final reason)) => _api.post(ApiPaths.rejection(id), body: RejectionDto(reason: reason).toJson()),
      (_, Archived()) => _api.post(ApiPaths.archival(id)),
      _ => throw ArgumentError.value(ascent, 'ascent', 'Nepoznat prelaz: $from -> ${ascent.status}'),
    };
    return resultOf(answer, _ascent);
  }

  Ascent _ascent(Object? json) => AscentDto.fromJson(object(json)).toDomain();
}
