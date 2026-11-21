import 'package:domain/domain.dart';

String errorMessage(DomainError error) => switch (error) {
  TitleTooShort(:final length) =>
  'Naslov ima $length ${_znakova(length)}, a treba bar ${AscentTitle.minLength}.',
  DescriptionTooLong(:final length) =>
  'Opis ima $length ${_znakova(length)}, a najvise je ${AscentDescription.maxLength}.',
  TooFewWaypoints(:final count) =>
  'Staza ima $count ${_tacaka(count)}, a treba bar ${AscentLimits.minWaypoints}: polazak i vrh.',
  InvalidDistance(:final distanceKm) =>
  'Duzina ${_km(distanceKm)} nije u opsegu od ${_km(AscentLimits.minDistanceKm)} do ${_km(AscentLimits.maxDistanceKm)}.',
  StartNotBelowSummit(:final startAltitudeM, :final summitAltitudeM) =>
  'Polazak je na $startAltitudeM m, a vrh na $summitAltitudeM m. Vrh mora biti visi od polaska.',
  InvalidTransition(:final from, :final to) =>
  'Iz stanja "${statusLabel(from)}" ne moze u "${statusLabel(to)}". Staza je u medjuvremenu promenjena.',
  AuthorCannotConfirm() => 'Svoju stazu ne mozete sami da potvrdite.',
  AlreadyConfirmed() => 'Vec ste potvrdili ovu stazu.',
  ReasonRequired() => 'Upisite razlog odbijanja.',
  AscentLocked() => 'Staza je u stanju u kojem se vise ne menja.',
  NotAllowed() => 'Za ovu radnju nemate ovlascenje.',
  NotFound() => 'Staza nije pronadjena.',
};

String statusLabel(AscentStatus status) => switch (status) {
  Draft() => 'priprema',
  Proposed() => 'ceka potvrde',
  Confirmed() => 'potvrdjena',
  Published() => 'objavljena',
  Rejected() => 'odbijena',
  Archived() => 'arhivirana',
};

String confirmationsLeft(int confirmations) {
  final left = requiredConfirmations - confirmations;
  if (left <= 0) return 'Skupljene su sve potvrde.';
  return 'Ceka jos $left ${_potvrda(left)}.';
}

String _znakova(int n) => n % 10 == 1 && n % 100 != 11 ? 'znak' : 'znakova';

String _tacaka(int n) => n == 1 ? 'tacku' : 'tacaka';

String _potvrda(int n) => n == 1 ? 'potvrdu' : 'potvrde';

String _km(double km) => '${km.toStringAsFixed(km == km.roundToDouble() ? 0 : 1)} km';
