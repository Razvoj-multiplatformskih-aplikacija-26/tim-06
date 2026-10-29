
import 'package:domain/src/geo_point.dart';
import 'package:domain/src/identifiers.dart';
import 'package:meta/meta.dart';

@immutable
final class Mountain {
  final MountainId id;
  final String name;
  final String country;
  final GeoPoint position;

  const Mountain(this.id, this.name, this.country, this.position);

  @override
  bool operator ==(Object other) =>
      other is Mountain &&
          id == other.id &&
          name == other.name &&
          country == other.country &&
          position == other.position;

  @override
  int get hashCode => Object.hash(id, name, country, position);

  @override
  String toString() => 'Mountain($name, $country)';
}