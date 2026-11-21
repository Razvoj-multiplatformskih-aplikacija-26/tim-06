import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

extension GeoPointToDto on GeoPoint {
  GeoPointDto toDto() => GeoPointDto(lat: lat, lon: lon);
}

extension GeoPointFromDto on GeoPointDto {
  GeoPoint toDomain() => GeoPoint(lat, lon);
}

extension MountainToDto on Mountain {
  MountainDto toDto() => MountainDto(id: id.value, name: name, country: country, position: position.toDto());
}

extension MountainFromDto on MountainDto {
  Mountain toDomain() => Mountain(MountainId(id), name, country, position.toDomain());
}

extension PeakToDto on Peak {
  PeakDto toDto() => PeakDto(
    id: id.value,
    name: name,
    mountainId: mountainId.value,
    altitudeM: altitudeM,
    position: position.toDto(),
  );
}

extension PeakFromDto on PeakDto {
  Peak toDomain() => Peak(PeakId(id), name, MountainId(mountainId), altitudeM, position.toDomain());
}

extension UserToDto on User {
  UserDto toDto() => UserDto(id: id.value, username: username, role: role.name);
}

extension UserFromDto on UserDto {
  User toDomain() => User(UserId(id), username, roleFromJson(role));
}

Role roleFromJson(String value) {
  for (final role in Role.values) {
    if (role.name == value) return role;
  }
  throw FormatException('Nepoznata uloga', value);
}

Difficulty difficultyFromJson(String value) {
  for (final difficulty in Difficulty.values) {
    if (difficulty.name == value) return difficulty;
  }
  throw FormatException('Nepoznata tezina', value);
}