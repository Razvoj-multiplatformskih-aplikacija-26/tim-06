import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

import 'ascent_mapping.dart';

extension DomainErrorToProblem on DomainError {
  ProblemDto toProblem() => switch (this) {
    TitleTooShort(:final length) => ProblemDto(
      status: 422,
      code: ErrorCodes.titleTooShort,
      title: 'Naslov je kraci od najmanje duzine',
      value: length,
      min: AscentTitle.minLength,
    ),
    DescriptionTooLong(:final length) => ProblemDto(
      status: 422,
      code: ErrorCodes.descriptionTooLong,
      title: 'Opis je duzi od najvece duzine',
      value: length,
      max: AscentDescription.maxLength,
    ),
    TooFewWaypoints(:final count) => ProblemDto(
      status: 422,
      code: ErrorCodes.tooFewWaypoints,
      title: 'Premalo tacaka na putu',
      value: count,
      min: AscentLimits.minWaypoints,
    ),
    InvalidDistance(:final distanceKm) => ProblemDto(
      status: 422,
      code: ErrorCodes.invalidDistance,
      title: 'Duzina staze je van dozvoljenog opsega',
      value: distanceKm,
      min: AscentLimits.minDistanceKm,
      max: AscentLimits.maxDistanceKm,
    ),
    StartNotBelowSummit(:final startAltitudeM, :final summitAltitudeM) => ProblemDto(
      status: 422,
      code: ErrorCodes.startNotBelowSummit,
      title: 'Pocetak nije nizi od vrha',
      value: startAltitudeM,
      max: summitAltitudeM,
    ),
    InvalidTransition(:final from, :final to) => ProblemDto(
      status: 409,
      code: ErrorCodes.invalidTransition,
      title: 'Prelaz izmedju stanja nije dozvoljen',
      from: from.toDto(),
      to: to.toDto(),
    ),
    AuthorCannotConfirm() => const ProblemDto(
      status: 422,
      code: ErrorCodes.authorCannotConfirm,
      title: 'Autor ne potvrdjuje sopstvenu stazu',
    ),
    AlreadyConfirmed() => const ProblemDto(
      status: 409,
      code: ErrorCodes.alreadyConfirmed,
      title: 'Ovaj planinar je vec potvrdio stazu',
    ),
    ReasonRequired() => const ProblemDto(
      status: 422,
      code: ErrorCodes.reasonRequired,
      title: 'Odbijanje trazi razlog',
    ),
    AscentLocked() => const ProblemDto(
      status: 409,
      code: ErrorCodes.ascentLocked,
      title: 'Staza se u ovom stanju vise ne menja',
    ),
    NotAllowed() => const ProblemDto(status: 403, code: ErrorCodes.notAllowed, title: 'Nije dozvoljeno'),
    NotFound() => const ProblemDto(status: 404, code: ErrorCodes.notFound, title: 'Nije pronadjeno'),
  };
}

extension ProblemToDomainError on ProblemDto {
  DomainError? toDomainError() => switch (this) {
    ProblemDto(code: ErrorCodes.titleTooShort, :final value?) => TitleTooShort(value.toInt()),
    ProblemDto(code: ErrorCodes.descriptionTooLong, :final value?) => DescriptionTooLong(value.toInt()),
    ProblemDto(code: ErrorCodes.tooFewWaypoints, :final value?) => TooFewWaypoints(value.toInt()),
    ProblemDto(code: ErrorCodes.invalidDistance, :final value?) => InvalidDistance(value.toDouble()),
    ProblemDto(code: ErrorCodes.startNotBelowSummit, :final value?, :final max?) => StartNotBelowSummit(
      value.toInt(),
      max.toInt(),
    ),
    ProblemDto(code: ErrorCodes.invalidTransition, :final from?, :final to?) => InvalidTransition(
      from.toDomain(),
      to.toDomain(),
    ),
    ProblemDto(code: ErrorCodes.authorCannotConfirm) => const AuthorCannotConfirm(),
    ProblemDto(code: ErrorCodes.alreadyConfirmed) => const AlreadyConfirmed(),
    ProblemDto(code: ErrorCodes.reasonRequired) => const ReasonRequired(),
    ProblemDto(code: ErrorCodes.ascentLocked) => const AscentLocked(),
    ProblemDto(code: ErrorCodes.notAllowed) => const NotAllowed(),
    ProblemDto(code: ErrorCodes.notFound) => const NotFound(),
    _ => null,
  };
}
