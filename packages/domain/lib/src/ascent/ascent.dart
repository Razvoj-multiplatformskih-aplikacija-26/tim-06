
import 'package:domain/src/ascent/waypoint.dart';
import 'package:meta/meta.dart';

import '../geo_point.dart';
import '../identifiers.dart';
import 'ascent_description.dart';
import 'ascent_status.dart';
import 'package:collection/collection.dart';

import 'ascent_title.dart';

enum Difficulty {
  easy,
  moderate,
  hard
}

abstract final class AscentLimits {
  static const minDistanceKm = 0.5;
  static const maxDistanceKm = 60.0;
  static const minWaypoints = 2;

  static bool isValidDistance(double km) => km >= minDistanceKm && km <= maxDistanceKm;
}

@immutable
final class Ascent {
  final AscentId id;
  final PeakId peakId;
  final UserId authorId;
  final AscentTitle title;
  final AscentDescription? description;
  final Difficulty difficulty;
  final double distanceKm;
  final List<Waypoint> waypoints;
  final List<GeoPoint> track;
  final AscentStatus status;
  final DateTime createdAt;

  const Ascent(this.id, this.peakId, this.authorId, this.title, this.description,
      this.difficulty, this.distanceKm, this.waypoints, this.track, this.status,
      this.createdAt);

  Waypoint get start => waypoints.first;

  Waypoint get summit => waypoints.last;

  int get climbM => summit.altitudeM - start.altitudeM;

  int get estimatedMinutes => (distanceKm * 15).round() + (climbM / 10).round();

  bool get isPublic => status is Published;

  Ascent copyWith({
    AscentTitle? title,
    AscentDescription? description,
    Difficulty? difficulty,
    double? distanceKm,
    AscentStatus? status,
  }) {
    return Ascent(
      id,
      peakId,
      authorId,
      title ?? this.title,
      description ?? this.description,
      difficulty ?? this.difficulty,
      distanceKm ?? this.distanceKm,
      waypoints,
      track,
      status ?? this.status,
      createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Ascent &&
          other.id == id &&
          other.peakId == peakId &&
          other.authorId == authorId &&
          other.title == title &&
          other.description == description &&
          other.difficulty == difficulty &&
          other.distanceKm == distanceKm &&
          const ListEquality<Waypoint>().equals(other.waypoints, waypoints) &&
          const ListEquality<GeoPoint>().equals(other.track, track) &&
          other.status == status &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    peakId,
    authorId,
    title,
    description,
    difficulty,
    distanceKm,
    const ListEquality<Waypoint>().hash(waypoints),
    const ListEquality<GeoPoint>().hash(track),
    status,
    createdAt,
  );

  @override
  String toString() => 'Ascent($id, ${title.text}, $status)';
}