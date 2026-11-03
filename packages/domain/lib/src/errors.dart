
import 'ascent/ascent_status.dart';

sealed class DomainError{
  const DomainError();
}

final class TitleTooShort extends DomainError{
  final int length;

  const TitleTooShort(this.length);


  @override
  bool operator ==(Object other) =>
      other is TitleTooShort &&
          length == other.length;

  @override
  int get hashCode => length.hashCode;

  @override
  String toString() => 'TitleTooShort($length)';

}

final class DescriptionTooLong extends DomainError{
  final int length;

  const DescriptionTooLong(this.length);


  @override
  bool operator ==(Object other) =>
      other is DescriptionTooLong &&
          length == other.length;

  @override
  int get hashCode => length.hashCode;

  @override
  String toString() => 'DescriptionTooLong($length)';

}

final class TooFewWaypoints extends DomainError {
  final int count;

  const TooFewWaypoints(this.count);

  @override
  bool operator ==(Object other) => other is TooFewWaypoints && other.count == count;

  @override
  int get hashCode => count.hashCode;

  @override
  String toString() => 'TooFewWaypoints($count)';
}

final class InvalidTransition extends DomainError {
  final AscentStatus from;
  final AscentStatus to;

  const InvalidTransition(this.from, this.to);

  @override
  bool operator ==(Object other) =>
      other is InvalidTransition &&
          from.runtimeType == other.from.runtimeType &&
          to.runtimeType == other.to.runtimeType;

  @override
  int get hashCode => Object.hash(from.runtimeType, to.runtimeType);

  @override
  String toString() => 'InvalidTransition(${from.runtimeType} -> ${to.runtimeType})';
}

final class AuthorCannotConfirm extends DomainError{
  const AuthorCannotConfirm();
}

final class StartNotBelowSummit extends DomainError {
  final int startAltitudeM;
  final int summitAltitudeM;

  const StartNotBelowSummit(this.startAltitudeM, this.summitAltitudeM);

  @override
  bool operator ==(Object other) =>
      other is StartNotBelowSummit &&
          other.startAltitudeM == startAltitudeM &&
          other.summitAltitudeM == summitAltitudeM;

  @override
  int get hashCode => Object.hash(startAltitudeM, summitAltitudeM);

  @override
  String toString() => 'StartNotBelowSummit($startAltitudeM, $summitAltitudeM)';
}

final class AlreadyConfirmed extends DomainError {
  const AlreadyConfirmed();
}

final class ReasonRequired extends DomainError {
  const ReasonRequired();
}

final class NotAllowed extends DomainError {
  const NotAllowed();
}

final class NotFound extends DomainError {
  const NotFound();
}

final class AscentLocked extends DomainError {
  const AscentLocked();
}
final class InvalidDistance extends DomainError {
  final double distanceKm;

  const InvalidDistance(this.distanceKm);

  @override
  bool operator ==(Object other) => other is InvalidDistance && other.distanceKm == distanceKm;

  @override
  int get hashCode => distanceKm.hashCode;

  @override
  String toString() => 'InvalidDistance($distanceKm)';
}
