import 'json.dart';

final class GeoPointDto {
  const GeoPointDto({required this.lat, required this.lon});

  final double lat;
  final double lon;

  Map<String, Object?> toJson() => {'lat': lat, 'lon': lon};

  factory GeoPointDto.fromJson(Map<String, Object?> json) =>
      GeoPointDto(lat: jsonDouble(json, 'lat'), lon: jsonDouble(json, 'lon'));
}

final class MountainDto {
  const MountainDto({required this.id, required this.name, required this.country, required this.position});

  final String id;
  final String name;
  final String country;
  final GeoPointDto position;

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'country': country, 'position': position.toJson()};

  factory MountainDto.fromJson(Map<String, Object?> json) => MountainDto(
    id: jsonString(json, 'id'),
    name: jsonString(json, 'name'),
    country: jsonString(json, 'country'),
    position: GeoPointDto.fromJson(jsonObject(json['position'])),
  );
}

final class PeakDto {
  const PeakDto({
    required this.id,
    required this.name,
    required this.mountainId,
    required this.altitudeM,
    required this.position,
  });

  final String id;
  final String name;
  final String mountainId;
  final int altitudeM;
  final GeoPointDto position;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'mountainId': mountainId,
    'altitudeM': altitudeM,
    'position': position.toJson(),
  };

  factory PeakDto.fromJson(Map<String, Object?> json) => PeakDto(
    id: jsonString(json, 'id'),
    name: jsonString(json, 'name'),
    mountainId: jsonString(json, 'mountainId'),
    altitudeM: jsonInt(json, 'altitudeM'),
    position: GeoPointDto.fromJson(jsonObject(json['position'])),
  );
}

final class UserDto {
  const UserDto({required this.id, required this.username, required this.role});

  final String id;
  final String username;
  final String role;

  Map<String, Object?> toJson() => {'id': id, 'username': username, 'role': role};

  factory UserDto.fromJson(Map<String, Object?> json) => UserDto(
    id: jsonString(json, 'id'),
    username: jsonString(json, 'username'),
    role: jsonString(json, 'role'),
  );
}

final class CatalogDto {
  const CatalogDto({required this.mountains, required this.peaks, required this.users});

  final List<MountainDto> mountains;
  final List<PeakDto> peaks;
  final List<UserDto> users;

  Map<String, Object?> toJson() => {
    'mountains': [for (final mountain in mountains) mountain.toJson()],
    'peaks': [for (final peak in peaks) peak.toJson()],
    'users': [for (final user in users) user.toJson()],
  };

  factory CatalogDto.fromJson(Map<String, Object?> json) => CatalogDto(
    mountains: [for (final item in jsonObjects(json, 'mountains')) MountainDto.fromJson(item)],
    peaks: [for (final item in jsonObjects(json, 'peaks')) PeakDto.fromJson(item)],
    users: [for (final item in jsonObjects(json, 'users')) UserDto.fromJson(item)],
  );
}

