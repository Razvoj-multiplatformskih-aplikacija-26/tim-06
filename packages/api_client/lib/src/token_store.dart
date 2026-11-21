/// Vrata ka mestu na kojem platforma cuva prijavu. Telefon i desktop iza ovoga
/// drze Keychain, Keystore ili Credential Manager; pregledac nista, jer tamo
/// prijavu drzi kolacic koji JavaScript ne vidi.
abstract interface class TokenStore {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> clear();
}

final class MemoryTokenStore implements TokenStore {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
