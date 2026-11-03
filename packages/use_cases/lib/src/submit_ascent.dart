import 'package:domain/domain.dart';
import 'package:use_cases/src/ports/ascent_repository.dart';

import 'change_status.dart';
import 'clock.dart';

final class SubmitAscent {
  final AscentRepository ascents;
  const SubmitAscent({required this.ascents});


  Future<Result<Ascent>> call({required AscentId id, required User by}) =>
      changeStatus(ascents, id, change: (ascent) => submitAscent(ascent, by: by));
}