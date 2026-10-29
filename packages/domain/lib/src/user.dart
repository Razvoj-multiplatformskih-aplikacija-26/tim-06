import 'package:domain/src/identifiers.dart';
import 'package:meta/meta.dart';

enum Role{
  hiker,
  moderator;
  
  bool get isModerator => this == Role.moderator;
}

@immutable
final class User {
  final UserId id;
  final String username;
  final Role role;

  const User(this.id, this.username, this.role);

  @override
  bool operator ==(Object other) =>
      other is User &&
          id == other.id &&
          username == other.username &&
          role == other.role;

  @override
  int get hashCode => Object.hash(id, username, role);

  @override
  String toString() => 'User($username, $role)';

}