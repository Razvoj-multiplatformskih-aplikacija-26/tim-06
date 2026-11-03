import 'package:domain/domain.dart';
import 'package:use_cases/src/ports/ascent_repository.dart';

import 'change_status.dart';
import 'clock.dart';

final class RejectAscent {

  final AscentRepository ascents;
  final Clock clock;
  const RejectAscent({required this.ascents, required this.clock});


  Future<Result<Ascent>> call({required AscentId id, required User by, required String reason}) => changeStatus(
    ascents,
    id,
    change: (ascent) => rejectAscent(ascent, by: by, now: clock.now(), reason: reason),
  );
}