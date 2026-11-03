import '../errors.dart';
import '../result.dart';
import '../user.dart';
import 'access_policy.dart';
import 'ascent.dart';
import 'ascent_description.dart';
import 'ascent_status.dart';
import 'ascent_title.dart';

Result<Ascent> editAscent(
    Ascent ascent, {
      required User by,
      AscentTitle? title,
      Difficulty? difficulty,
      double? distanceKm,
      AscentDescription? description,
    }) {
  if (!AccessPolicy.canEdit(by, ascent)) return const Failure(NotAllowed());

  final status = ascent.status;
  if (status is Rejected || status is Archived) return const Failure(AscentLocked());

  final changesMoreThanDescription = title != null || difficulty != null || distanceKm != null;
  if (status is Published && changesMoreThanDescription) return const Failure(AscentLocked());

  if (distanceKm != null && !AscentLimits.isValidDistance(distanceKm)) return Failure(InvalidDistance(distanceKm));

  return Success(
    ascent.copyWith(title: title, difficulty: difficulty, distanceKm: distanceKm, description: description),
  );
}