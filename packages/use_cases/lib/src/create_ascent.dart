import 'package:domain/domain.dart';
import 'package:use_cases/src/ports/ascent_repository.dart';

import 'change_status.dart';
import 'clock.dart';

final class CreateAscentUseCase {
  final AscentRepository ascents;
  final Clock clock;
  const CreateAscentUseCase({required this.ascents, required this.clock});


  Future<Result<Ascent>> call({
    required AscentId id,
    required PeakId peakId,
    required User author,
    required String title,
    required Difficulty difficulty,
    required double distanceKm,
    required List<Waypoint> waypoints,
    String? description,
    List<GeoPoint> track = const <GeoPoint>[],
  }) async {
    final result = createAscent(
      id: id,
      peakId: peakId,
      author: author,
      title: title,
      difficulty: difficulty,
      distanceKm: distanceKm,
      waypoints: waypoints,
      now: clock.now(),
      description: description,
      track: track,
    );
    return switch (result) {
      Failure<Ascent>() => result,
      Success<Ascent>(:final value) => Success(await ascents.add(value)),
    };
  }
}