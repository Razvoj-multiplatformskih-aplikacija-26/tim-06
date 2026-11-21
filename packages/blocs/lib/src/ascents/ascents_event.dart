import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

sealed class AscentsEvent extends Equatable {
  const AscentsEvent();

  @override
  List<Object?> get props => const [];
}

final class AscentsRequested extends AscentsEvent {
  const AscentsRequested();
}

final class AscentErrorCleared extends AscentsEvent {
  const AscentErrorCleared();
}

final class AscentCreated extends AscentsEvent {
  const AscentCreated({
    required this.peakId,
    required this.title,
    required this.difficulty,
    required this.distanceKm,
    required this.waypoints,
    this.description,
    this.track = const <GeoPoint>[],
  });

  final PeakId peakId;
  final String title;
  final Difficulty difficulty;
  final double distanceKm;
  final List<Waypoint> waypoints;
  final String? description;
  final List<GeoPoint> track;

  @override
  List<Object?> get props => [peakId.value, title, difficulty, distanceKm, waypoints, description];
}

final class AscentSubmitted extends AscentsEvent {
  const AscentSubmitted(this.id);

  final AscentId id;

  @override
  List<Object?> get props => [id.value];
}

final class AscentConfirmed extends AscentsEvent {
  const AscentConfirmed(this.id);

  final AscentId id;

  @override
  List<Object?> get props => [id.value];
}

final class AscentPublished extends AscentsEvent {
  const AscentPublished(this.id);

  final AscentId id;

  @override
  List<Object?> get props => [id.value];
}

final class AscentRejected extends AscentsEvent {
  const AscentRejected(this.id, this.reason);

  final AscentId id;
  final String reason;

  @override
  List<Object?> get props => [id.value, reason];
}

final class AscentArchived extends AscentsEvent {
  const AscentArchived(this.id);

  final AscentId id;

  @override
  List<Object?> get props => [id.value];
}
