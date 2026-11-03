
import '../user.dart';
import 'ascent.dart';
import 'ascent_status.dart';

abstract final class AccessPolicy {
  static bool canView(User user, Ascent ascent) => switch (ascent.status) {
    Published() || Proposed() || Confirmed() => true,
    Draft() => ascent.authorId == user.id,
    Rejected() || Archived() => user.role.isModerator || ascent.authorId == user.id,
  };

  static bool canCreate(User user) => user.role == Role.hiker;

  static bool canSubmit(User user, Ascent ascent) => ascent.authorId == user.id;

  static bool canConfirm(User user) => user.role == Role.hiker;

  static bool canPublish(User user) => user.role.isModerator;

  static bool canReject(User user) => user.role.isModerator;

  static bool canArchive(User user, Ascent ascent) => switch (ascent.status) {
    Draft() || Proposed() => ascent.authorId == user.id,
    Published() => user.role.isModerator,
    Confirmed() || Rejected() || Archived() => false,
  };

  static bool canEdit(User user, Ascent ascent) => user.role.isModerator || ascent.authorId == user.id;
}