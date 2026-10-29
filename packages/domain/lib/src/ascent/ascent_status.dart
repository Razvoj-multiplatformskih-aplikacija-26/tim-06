
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import '../identifiers.dart';

sealed class AscentStatus {
  const AscentStatus();

  bool get isDraft => this is Draft;

  bool get isOpen => switch (this) {
    Draft() || Proposed() || Confirmed() => true,
    Published() || Rejected() || Archived() => false,
  };

  bool get isFinal => switch (this) {
    Rejected() || Archived() => true,
    Draft() || Proposed() || Confirmed() || Published() => false,
  };
}

final class Draft extends AscentStatus {
  const Draft();

  @override
  String toString() => 'Draft';
}

@immutable
final class Proposed extends AscentStatus {

  final Set<UserId> confirmedBy;

  const Proposed(this.confirmedBy);

  int get confirmations => confirmedBy.length;

  @override
  bool operator ==(Object other) =>
      other is Proposed &&
          const SetEquality<UserId>().equals(other.confirmedBy, confirmedBy);

  @override
  int get hashCode => const SetEquality<UserId>().hash(confirmedBy);

  @override
  String toString() => 'Proposed($confirmations potvrda)';
}

@immutable
final class Confirmed extends AscentStatus {

  final Set<UserId> confirmedBy;
  final DateTime at;


  const Confirmed(this.confirmedBy, this.at);

  @override
  bool operator ==(Object other) =>
      other is Confirmed && const SetEquality<UserId>().equals(other.confirmedBy, confirmedBy) && other.at == at;

  @override
  int get hashCode => Object.hash(const SetEquality<UserId>().hash(confirmedBy), at);

  @override
  String toString() => 'Confirmed(${confirmedBy.length} potvrde)';
}

@immutable
final class Published extends AscentStatus {

  final UserId publishedBy;
  final DateTime at;

  const Published(this.publishedBy, this.at);

  @override
  bool operator ==(Object other) => other is Published && other.publishedBy == publishedBy && other.at == at;

  @override
  int get hashCode => Object.hash(publishedBy, at);

  @override
  String toString() => 'Published(by $publishedBy at $at)';
}

@immutable
final class Rejected extends AscentStatus {
  final String reason;
  final UserId rejectedBy;
  final DateTime at;


  const Rejected(this.reason, this.rejectedBy, this.at);

  @override
  bool operator ==(Object other) =>
      other is Rejected && other.reason == reason && other.rejectedBy == rejectedBy && other.at == at;

  @override
  int get hashCode => Object.hash(reason, rejectedBy, at);

  @override
  String toString() => 'Rejected("$reason" by $rejectedBy at $at)';
}

@immutable
final class Archived extends AscentStatus {

  final UserId archivedBy;
  final DateTime at;

  const Archived(this.archivedBy, this.at);

  @override
  bool operator ==(Object other) => other is Archived && other.archivedBy == archivedBy && other.at == at;

  @override
  int get hashCode => Object.hash(archivedBy, at);

  @override
  String toString() => 'Archived(by $archivedBy at $at)';
}

bool canTransition(AscentStatus from, AscentStatus to) => switch ((from, to)) {
  (Draft(), Proposed()) => true,
  (Draft(), Archived()) => true,
  (Proposed(), Confirmed()) => true,
  (Proposed(), Archived()) => true,
  (Confirmed(), Published()) => true,
  (Confirmed(), Rejected()) => true,
  (Published(), Archived()) => true,
  _ => false,
};