import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart';

final class Account {
  const Account({required this.user, required this.passwordHash});

  final User user;
  final String passwordHash;
}

final class AccountStore {
  const AccountStore(this._database);

  final Pool<void> _database;

  Future<Account?> account(String login) async {
    final rows = await _database.execute(
      Sql.named(
        'SELECT id, username, role, password_hash FROM users WHERE login = @login AND password_hash IS NOT NULL',
      ),
      parameters: {'login': login},
    );
    if (rows.isEmpty) return null;
    final [id, username, role, hash] = rows.single;
    return Account(
      user: User(UserId(id! as String), username! as String, Role.values.byName(role! as String)),
      passwordHash: hash! as String,
    );
  }
}
