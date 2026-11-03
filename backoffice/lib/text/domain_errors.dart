
import 'package:domain/domain.dart';

String messageFor(DomainError error) => switch (error) {
  TitleTooShort(:final length) => 'Naziv mora imati bar 3 znaka, a ima $length.',
  DescriptionTooLong(:final length) => 'Opis može imati najviše 200 znakova, a ima $length.',
  InvalidDistance() => 'Dužina mora biti između 0,5 i 60 km.',
  TooFewWaypoints() => 'Staza mora imati bar polazak i vrh.',
  StartNotBelowSummit(:final summitAltitudeM) => 'Polazak mora biti niži od vrha ($summitAltitudeM m).',
  AuthorCannotConfirm() => 'Svoju stazu ne možete da potvrdite.',
  AlreadyConfirmed() => 'Ovu stazu ste već potvrdili.',
  ReasonRequired() => 'Unesite razlog odbijanja, autor treba da zna šta da popravi.',
  AscentLocked() => 'Ova staza se više ne menja.',
  InvalidTransition() => 'Ova radnja nije moguća u trenutnom stanju staze.',
  NotAllowed() => 'Nemate ovlašćenje za ovu radnju.',
  NotFound() => 'Staza nije pronađena.',
};