import 'package:domain/domain.dart';
import 'package:fake_data/fake_data.dart';
import 'package:postgres/postgres.dart';

import 'ascent_store.dart';
import 'passwords.dart';

Future<void> seedDemoData(Pool<void> database, {required String? demoPassword}) async {
  if (!await AscentStore(database).isEmpty()) return;
  if (demoPassword == null) {
    throw StateError('DEMO_PASSWORD nije postavljen. Kopirajte .env.example u .env.');
  }
  final hashes = <String, String>{
    for (final id in demoLogins.keys) id: await hashPassword(demoPassword),
  };
  await database.runTx((transaction) => _seed(transaction, hashes));
}

Future<void> _seed(Session database, Map<String, String> hashes) async {
  for (final user in seedUsers) {
    await database.execute(
      Sql.named(
        'INSERT INTO users (id, username, role, login, password_hash) VALUES (@id, @username, @role, @login, @hash)',
      ),
      parameters: {
        'id': user.id.value,
        'username': user.username,
        'role': user.role.name,
        'login': demoLogins[user.id.value],
        'hash': hashes[user.id.value],
      },
    );
  }

  for (final mountain in seedMountains) {
    await database.execute(
      Sql.named('INSERT INTO mountains (id, name, country, lat, lon) VALUES (@id, @name, @country, @lat, @lon)'),
      parameters: {
        'id': mountain.id.value,
        'name': mountain.name,
        'country': mountain.country,
        'lat': mountain.position.lat,
        'lon': mountain.position.lon,
      },
    );
  }

  for (final peak in seedPeaks) {
    await database.execute(
      Sql.named(
        'INSERT INTO peaks (id, name, mountain_id, altitude_m, lat, lon) '
            'VALUES (@id, @name, @mountain, @altitude, @lat, @lon)',
      ),
      parameters: {
        'id': peak.id.value,
        'name': peak.name,
        'mountain': peak.mountainId.value,
        'altitude': peak.altitudeM,
        'lat': peak.position.lat,
        'lon': peak.position.lon,
      },
    );
  }

  final store = AscentStore(database);
  for (final ascent in seedAscents()) {
    await store.insert(ascent);
    for (final by in _confirmers(ascent.status)) {
      await store.addConfirmation(ascent.id, by, ascent.createdAt);
    }
  }
}

Set<UserId> _confirmers(AscentStatus status) => switch (status) {
  Proposed(:final confirmedBy) => confirmedBy,
  Confirmed(:final confirmedBy) => confirmedBy,
  Draft() || Published() || Rejected() || Archived() => const <UserId>{},
};
