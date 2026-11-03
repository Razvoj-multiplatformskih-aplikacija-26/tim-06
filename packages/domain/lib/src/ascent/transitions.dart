import '../errors.dart';
import '../identifiers.dart';
import '../result.dart';
import '../user.dart';
import 'access_policy.dart';
import 'ascent.dart';
import 'ascent_status.dart';

const requiredConfirmations = 2;

Result<Ascent> submitAscent(Ascent ascent, {required User by}) {
  if (!AccessPolicy.canSubmit(by, ascent)) return const Failure(NotAllowed());
  return _transition(ascent, const Proposed({}));
}

Result<Ascent> confirmAscent(Ascent ascent, {required User by, required DateTime now}) {
  if (!AccessPolicy.canConfirm(by)) return const Failure(NotAllowed());
  if (ascent.authorId == by.id) return const Failure(AuthorCannotConfirm());

  final status = ascent.status;
  if (status is! Proposed) {
    return Failure(
      InvalidTransition(
        status,
        Confirmed(const <UserId>{},now.toUtc()),
      ),
    );
  }
  if (status.confirmedBy.contains(by.id)) return const Failure(AlreadyConfirmed());

  final confirmedBy = {...status.confirmedBy, by.id};
  if (confirmedBy.length >= requiredConfirmations) {
    return _transition(ascent, Confirmed(confirmedBy,now.toUtc()));
  }
  return Success(ascent.copyWith(status: Proposed(confirmedBy)));
}

Result<Ascent> publishAscent(Ascent ascent, {required User by, required DateTime now}) {
  if (!AccessPolicy.canPublish(by)) return const Failure(NotAllowed());
  return _transition(ascent, Published(by.id,now.toUtc()));
}

Result<Ascent> rejectAscent(Ascent ascent, {required User by, required DateTime now, required String reason}) {
  if (!AccessPolicy.canReject(by)) return const Failure(NotAllowed());
  final text = reason.trim();
  if (text.isEmpty) return const Failure(ReasonRequired());
  return _transition(ascent, Rejected(text,by.id,now.toUtc()));
}

Result<Ascent> archiveAscent(Ascent ascent, {required User by, required DateTime now}) {
  if (!AccessPolicy.canArchive(by, ascent)) return const Failure(NotAllowed());
  return _transition(ascent, Archived(by.id,now.toUtc()));
}

Result<Ascent> _transition(Ascent ascent, AscentStatus next) {
  if (!canTransition(ascent.status, next)) {
    return Failure(InvalidTransition(ascent.status,next));
  }
  return Success(ascent.copyWith(status: next));
}