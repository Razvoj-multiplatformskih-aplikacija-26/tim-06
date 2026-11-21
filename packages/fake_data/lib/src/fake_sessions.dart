import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'seed_data.dart';

final class FakeSessions implements SessionRepository {
  FakeSessions({User? signedInAs}) : _current = signedInAs;

  User? _current;

  @override
  Future<User?> logIn({required String username, required String password}) async {
    if (password.isEmpty) return null;
    for (final user in seedUsers) {
      if (user.username == username || demoLogins[user.id.value] == username) return _current = user;
    }
    return null;
  }

  @override
  Future<User?> current() async => _current;

  @override
  Future<void> logOut() async => _current = null;

  @override
  Stream<void> get expirations => const Stream<void>.empty();
}
