import '../errors.dart';
import '../geo_point.dart';
import '../identifiers.dart';
import '../result.dart';
import '../user.dart';
import 'access_policy.dart';
import 'ascent.dart';
import 'ascent_description.dart';
import 'ascent_status.dart';
import 'ascent_title.dart';
import 'waypoint.dart';


Result<Ascent> createAscent({
  required AscentId id,
  required PeakId peakId,
  required User author,
  required String title,
  required Difficulty difficulty,
  required double distanceKm,
  required List<Waypoint> waypoints,
  required DateTime now,
  String? description,
  List<GeoPoint> track = const <GeoPoint>[],
}) {
  if (!AccessPolicy.canCreate(author)) return const Failure(NotAllowed());

  final parsedTitle = AscentTitle.parse(title);
  final titleError = parsedTitle.errorOrNull;
  if (titleError != null) return Failure(titleError);

  AscentDescription? parsedDescription;
  if (description != null) {
    final result = AscentDescription.parse(description);
    final error = result.errorOrNull;
    if (error != null) return Failure(error);
    parsedDescription = result.valueOrNull;
  }

  if (!AscentLimits.isValidDistance(distanceKm)) return Failure(InvalidDistance(distanceKm));

  if (waypoints.length < AscentLimits.minWaypoints) return Failure(TooFewWaypoints(waypoints.length));

  final startAltitude = waypoints.first.altitudeM;
  final summitAltitude = waypoints.last.altitudeM;
  if (startAltitude >= summitAltitude) {
    return Failure(StartNotBelowSummit(startAltitude,summitAltitude));
  }

  return Success(
    Ascent(
      id,
      peakId,
      author.id,
      parsedTitle.valueOrNull!,
      parsedDescription,
      difficulty,
      distanceKm,
      waypoints,
      track,
      const Draft(),
      now.toUtc(),
    ),
  );
}