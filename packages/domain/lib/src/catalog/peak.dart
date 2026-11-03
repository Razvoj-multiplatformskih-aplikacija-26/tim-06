
import 'package:domain/src/geo_point.dart';
import 'package:domain/src/identifiers.dart';
import 'package:meta/meta.dart';

@immutable
final class Peak {

  final PeakId id;
  final String name;
  final MountainId mountainId;
  final int altitudeM;
  final GeoPoint position;

  const Peak(this.id, this.name, this.mountainId, this.altitudeM, this.position);


  @override
  bool operator ==(Object other) =>
      other is Peak &&
          id == other.id &&
          name == other.name &&
          mountainId == other.mountainId &&
          altitudeM == other.altitudeM &&
          position == other.position;

  @override
  int get hashCode => Object.hash(id, name, mountainId, altitudeM, position);

  @override
  String toString() => 'Peak($name, $altitudeM m)';
}