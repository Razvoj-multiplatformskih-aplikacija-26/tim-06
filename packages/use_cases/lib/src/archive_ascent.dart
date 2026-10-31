import 'package:domain/domain.dart';
import 'package:use_cases/src/ports/ascent_repository.dart';

import 'change_status.dart';
import 'clock.dart';

final class ArchiveAscent {
  final AscentRepository ascents;
  final Clock clock;
  const ArchiveAscent({required this.ascents, required this.clock});


  Future<Result<Ascent>> call({required AscentId id, required User by}) =>
      changeStatus(ascents, id, change: (ascent) => archiveAscent(ascent, by: by, now: clock.now()));
}