import 'catalog_dto.dart';
import 'json.dart';

final class WaypointDto {
  const WaypointDto({
    required this.distanceKm,
    required this.altitudeM,
    required this.name,
    this.note,
    this.position,
  });

  final double distanceKm;
  final int altitudeM;
  final String name;
  final String? note;
  final GeoPointDto? position;

  Map<String, Object?> toJson() => {
    'distanceKm': distanceKm,
    'altitudeM': altitudeM,
    'name': name,
    if (note != null) 'note': note,
    if (position case final position?) 'position': position.toJson(),
  };

  factory WaypointDto.fromJson(Map<String, Object?> json) => WaypointDto(
    distanceKm: jsonDouble(json, 'distanceKm'),
    altitudeM: jsonInt(json, 'altitudeM'),
    name: jsonString(json, 'name'),
    note: jsonOptionalString(json, 'note'),
    position: json['position'] == null ? null : GeoPointDto.fromJson(jsonObject(json['position'])),
  );
}

final class AscentStatusDto {
  const AscentStatusDto({required this.kind, this.confirmedBy = const [], this.by, this.at, this.reason});

  static const draft = 'draft';
  static const proposed = 'proposed';
  static const confirmed = 'confirmed';
  static const published = 'published';
  static const rejected = 'rejected';
  static const archived = 'archived';

  final String kind;
  final List<String> confirmedBy;
  final String? by;
  final DateTime? at;
  final String? reason;

  Map<String, Object?> toJson() => {
    'kind': kind,
    if (confirmedBy.isNotEmpty) 'confirmedBy': confirmedBy,
    if (by != null) 'by': by,
    if (at case final at?) 'at': instantToJson(at),
    if (reason != null) 'reason': reason,
  };

  factory AscentStatusDto.fromJson(Map<String, Object?> json) => AscentStatusDto(
    kind: jsonString(json, 'kind'),
    confirmedBy: jsonStrings(json, 'confirmedBy'),
    by: jsonOptionalString(json, 'by'),
    at: jsonOptionalInstant(json, 'at'),
    reason: jsonOptionalString(json, 'reason'),
  );
}

final class AscentDto {
  const AscentDto({
    required this.id,
    required this.peakId,
    required this.authorId,
    required this.title,
    required this.difficulty,
    required this.distanceKm,
    required this.waypoints,
    required this.status,
    required this.createdAt,
    this.description,
    this.track = const [],
  });

  final String id;
  final String peakId;
  final String authorId;
  final String title;
  final String? description;
  final String difficulty;
  final double distanceKm;
  final List<WaypointDto> waypoints;
  final List<GeoPointDto> track;
  final AscentStatusDto status;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'peakId': peakId,
    'authorId': authorId,
    'title': title,
    if (description != null) 'description': description,
    'difficulty': difficulty,
    'distanceKm': distanceKm,
    'waypoints': [for (final waypoint in waypoints) waypoint.toJson()],
    if (track.isNotEmpty) 'track': [for (final point in track) point.toJson()],
    'status': status.toJson(),
    'createdAt': instantToJson(createdAt),
  };

  factory AscentDto.fromJson(Map<String, Object?> json) => AscentDto(
    id: jsonString(json, 'id'),
    peakId: jsonString(json, 'peakId'),
    authorId: jsonString(json, 'authorId'),
    title: jsonString(json, 'title'),
    description: jsonOptionalString(json, 'description'),
    difficulty: jsonString(json, 'difficulty'),
    distanceKm: jsonDouble(json, 'distanceKm'),
    waypoints: [for (final item in jsonObjects(json, 'waypoints')) WaypointDto.fromJson(item)],
    track: json['track'] == null ? const [] : [for (final item in jsonObjects(json, 'track')) GeoPointDto.fromJson(item)],
    status: AscentStatusDto.fromJson(jsonObject(json['status'])),
    createdAt: jsonInstant(json, 'createdAt'),
  );
}

final class NewAscentDto {
  const NewAscentDto({
    required this.peakId,
    required this.title,
    required this.difficulty,
    required this.distanceKm,
    required this.waypoints,
    this.description,
    this.track = const [],
  });

  final String peakId;
  final String title;
  final String? description;
  final String difficulty;
  final double distanceKm;
  final List<WaypointDto> waypoints;
  final List<GeoPointDto> track;

  Map<String, Object?> toJson() => {
    'peakId': peakId,
    'title': title,
    if (description != null) 'description': description,
    'difficulty': difficulty,
    'distanceKm': distanceKm,
    'waypoints': [for (final waypoint in waypoints) waypoint.toJson()],
    if (track.isNotEmpty) 'track': [for (final point in track) point.toJson()],
  };

  factory NewAscentDto.fromJson(Map<String, Object?> json) => NewAscentDto(
    peakId: jsonString(json, 'peakId'),
    title: jsonString(json, 'title'),
    description: jsonOptionalString(json, 'description'),
    difficulty: jsonString(json, 'difficulty'),
    distanceKm: jsonDouble(json, 'distanceKm'),
    waypoints: [for (final item in jsonObjects(json, 'waypoints')) WaypointDto.fromJson(item)],
    track: json['track'] == null ? const [] : [for (final item in jsonObjects(json, 'track')) GeoPointDto.fromJson(item)],
  );
}

final class RejectionDto {
  const RejectionDto({required this.reason});

  final String reason;

  Map<String, Object?> toJson() => {'reason': reason};

  factory RejectionDto.fromJson(Map<String, Object?> json) => RejectionDto(reason: jsonString(json, 'reason'));
}
