
import 'package:domain/domain.dart';

String messageFor(DomainError error) => switch (error) {
  TitleTooShort(:final length) => 'Naziv mora imati bar 3 znaka, a ima $length.',
  DescriptionTooLong(:final length) => 'Opis moze imati najvise 200 znakova, a ima $length.',
  InvalidDistance() => 'Duzina mora biti izmedju 0,5 i 60 km.',
  TooFewWaypoints() => 'Staza mora imati bar polazak i vrh.',
  StartNotBelowSummit(:final summitAltitudeM) => 'Polazak mora biti nizi od vrha ($summitAltitudeM m).',
  AuthorCannotConfirm() => 'Svoju stazu ne mozete da potvrdite.',
  AlreadyConfirmed() => 'Ovu stazu ste vec potvrdili.',
  ReasonRequired() => 'Unesite razlog odbijanja.',
  AscentLocked() => 'Ova staza se vise ne menja.',
  InvalidTransition() => 'Ova radnja nije moguca u trenutnom stanju staze.',
  NotAllowed() => 'Nemate ovlascenje za ovu radnju.',
  NotFound() => 'Staza nije pronadjena.',
};