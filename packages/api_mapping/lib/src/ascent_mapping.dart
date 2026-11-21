import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

import 'catalog_mapping.dart';

extension WaypointToDto on Waypoint {
  WaypointDto toDto() => WaypointDto(
    distanceKm: distanceKm,
    altitudeM: altitudeM,
    name: name,
    note: note,
    position: position?.toDto(),
  );
}

extension WaypointFromDto on WaypointDto {
  Waypoint toDomain() => Waypoint(distanceKm, altitudeM, name, note, position?.toDomain());
}

extension AscentStatusToDto on AscentStatus {
  AscentStatusDto toDto() => switch (this) {
    Draft() => const AscentStatusDto(kind: AscentStatusDto.draft),
    Proposed(:final confirmedBy) => AscentStatusDto(
      kind: AscentStatusDto.proposed,
      confirmedBy: [for (final id in confirmedBy) id.value],
    ),
    Confirmed(:final confirmedBy, :final at) => AscentStatusDto(
      kind: AscentStatusDto.confirmed,
      confirmedBy: [for (final id in confirmedBy) id.value],
      at: at,
    ),
    Published(:final publishedBy, :final at) => AscentStatusDto(
      kind: AscentStatusDto.published,
      by: publishedBy.value,
      at: at,
    ),
    Rejected(:final reason, :final rejectedBy, :final at) => AscentStatusDto(
      kind: AscentStatusDto.rejected,
      by: rejectedBy.value,
      at: at,
      reason: reason,
    ),
    Archived(:final archivedBy, :final at) => AscentStatusDto(
      kind: AscentStatusDto.archived,
      by: archivedBy.value,
      at: at,
    ),
  };
}

extension AscentStatusFromDto on AscentStatusDto {
  AscentStatus toDomain() => switch (kind) {
    AscentStatusDto.draft => const Draft(),
    AscentStatusDto.proposed => Proposed({for (final id in confirmedBy) UserId(id)}),
    AscentStatusDto.confirmed => Confirmed({for (final id in confirmedBy) UserId(id)}, _at()),
    AscentStatusDto.published => Published(UserId(_by()), _at()),
    AscentStatusDto.rejected => Rejected(reason ?? '', UserId(_by()), _at()),
    AscentStatusDto.archived => Archived(UserId(_by()), _at()),
    _ => throw FormatException('Nepoznato stanje staze', kind),
  };

  DateTime _at() => at ?? (throw FormatException('Stanje "$kind" mora da nosi vreme', kind));

  String _by() => by ?? (throw FormatException('Stanje "$kind" mora da nosi ko ga je postavio', kind));
}

extension AscentToDto on Ascent {
  AscentDto toDto() => AscentDto(
    id: id.value,
    peakId: peakId.value,
    authorId: authorId.value,
    title: title.text,
    description: description?.text,
    difficulty: difficulty.name,
    distanceKm: distanceKm,
    waypoints: [for (final waypoint in waypoints) waypoint.toDto()],
    track: [for (final point in track) point.toDto()],
    status: status.toDto(),
    createdAt: createdAt,
  );
}

extension AscentFromDto on AscentDto {
  Ascent toDomain() => Ascent(
    AscentId(id),
    PeakId(peakId),
    UserId(authorId),
    _parsed(AscentTitle.parse(title), 'title'),
    description == null ? null : _parsed(AscentDescription.parse(description!), 'description'),
    difficultyFromJson(difficulty),
    distanceKm,
    [for (final waypoint in waypoints) waypoint.toDomain()],
    [for (final point in track) point.toDomain()],
    status.toDomain(),
    createdAt,
  );
}

extension CatalogFromDto on CatalogDto {
  List<Mountain> get mountainsDomain => [for (final item in mountains) item.toDomain()];

  List<Peak> get peaksDomain => [for (final item in peaks) item.toDomain()];

  List<User> get usersDomain => [for (final item in users) item.toDomain()];
}

T _parsed<T>(Result<T> result, String field) => switch (result) {
  Success<T>(:final value) => value,
  Failure<T>(:final error) => throw FormatException('Polje "$field" ne prolazi pravilo domena: $error'),
};
