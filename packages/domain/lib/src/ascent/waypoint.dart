
import 'package:domain/src/geo_point.dart';
import 'package:meta/meta.dart';

@immutable
final class Waypoint {

  final double distanceKm;
  final int altitudeM;
  final String name;
  final String? note;
  final GeoPoint? position;

  const Waypoint(this.distanceKm, this.altitudeM, this.name, this.note, this.position);


  @override
  bool operator ==(Object other) =>
          other is Waypoint &&
              distanceKm == other.distanceKm && altitudeM == other.altitudeM &&
              name == other.name && note == other.note &&
              position == other.position;

  @override
  int get hashCode => Object.hash(distanceKm, altitudeM, name, note, position);

  @override
  String toString() => 'Waypoint($name, $distanceKm km, $altitudeM m)';
}