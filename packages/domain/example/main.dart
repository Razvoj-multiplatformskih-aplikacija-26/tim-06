import 'package:domain/domain.dart';

void main() {
  final moderator = User(const UserId('u-mod'), 'moderator', Role.moderator);
  final ana = User(const UserId('u-ana'), 'ana', Role.hiker);
  final petar = User(const UserId('u-petar'), 'petar', Role.hiker);
  final jovana = User(const UserId('u-jovana'), 'jovana', Role.hiker);

  final waypoints = [
    Waypoint(0, 780, 'Topli Do', 'parking kod česme',null),
    Waypoint(3.6, 1120, 'Koliba', 'poslednja kuća',null),
    Waypoint(17.4, 2169, 'Midžor', 'granični kamen',null),
  ];

  print('--- 1. Pravimo stazu ---');
  final created = createAscent(
    id: const AscentId('a-1'),
    peakId: const PeakId('p-midzor'),
    author: ana,
    title: 'Midžor iz Topli Dola',
    difficulty: Difficulty.hard,
    distanceKm: 17.4,
    waypoints: waypoints,
    now: DateTime.now(),
    description: 'Voda samo na izvoru.',
  );
  print(created);

  var ascent = created.valueOrNull!;
  print('Stanje: ${ascent.status}');

  print('\n--- 2. Autor šalje na potvrdu ---');
  final submitted = submitAscent(ascent, by: ana);
  print(submitted);
  ascent = submitted.valueOrNull!;
  print('Stanje: ${ascent.status}');

  print('\n--- 3. Ana (autor) pokušava da potvrdi SVOJU stazu ---');
  final selfConfirm = confirmAscent(ascent, by: ana, now: DateTime.now());
  print(selfConfirm);

  print('\n--- 4. Petar potvrđuje (1. potvrda) ---');
  final firstConfirm = confirmAscent(ascent, by: petar, now: DateTime.now());
  print(firstConfirm);
  ascent = firstConfirm.valueOrNull!;
  print('Stanje: ${ascent.status}');

  print('\n--- 5. Petar pokušava da potvrdi DRUGI PUT ---');
  final duplicateConfirm = confirmAscent(ascent, by: petar, now: DateTime.now());
  print(duplicateConfirm);

  print('\n--- 6. Jovana potvrđuje (2. potvrda) ---');
  final secondConfirm = confirmAscent(ascent, by: jovana, now: DateTime.now());
  print(secondConfirm);
  ascent = secondConfirm.valueOrNull!;
  print('Stanje: ${ascent.status}');

  print('\n--- 7. Moderator objavljuje ---');
  final published = publishAscent(ascent, by: moderator, now: DateTime.now());
  print(published);
  ascent = published.valueOrNull!;
  print('Stanje: ${ascent.status}');

  print('\n--- 8. Ana pokušava da promeni NAZIV objavljene staze ---');
  final editTitle = editAscent(ascent, by: ana, title: AscentTitle.parse('Novi naziv').valueOrNull);
  print(editTitle);

  print('\n--- 9. Ana menja SAMO opis objavljene staze ---');
  final editDescription = editAscent(
    ascent,
    by: ana,
    description: AscentDescription.parse('Ažuriran opis.').valueOrNull,
  );
  print(editDescription);

  print('\n--- 10. Pokušaj pravljenja staze sa prekratkim nazivom ---');
  final badTitle = createAscent(
    id: const AscentId('a-2'),
    peakId: const PeakId('p-avala'),
    author: ana,
    title: 'Mi',
    difficulty: Difficulty.easy,
    distanceKm: 6.4,
    waypoints: waypoints,
    now: DateTime.now(),
  );
  print(badTitle);
}