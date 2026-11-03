import 'package:meta/meta.dart';

@immutable
final class GeoPoint{
  final double lat;
  final double lon;

  const GeoPoint(this.lat, this.lon);


  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
          lat == other.lat &&
          lon == other.lon;

  @override
  int get hashCode => Object.hash(lat, lon);

  @override
  String toString() => 'GeoPoint($lat,$lon)';

}