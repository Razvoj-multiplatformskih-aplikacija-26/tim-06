import 'package:flutter/foundation.dart';

/// Gde je server, bez izmene koda po platformi.
///
/// Android emulator ne vidi `localhost` racunara (to je sam emulator), nego ga
/// zove preko 10.0.2.2. Pravi telefon ili drugi racunar dobijaju adresu preko
/// --dart-define=SERVER_URL=..., pa se ni tada nista ne menja u kodu.
Uri serverAddress() {
  const configured = String.fromEnvironment('SERVER_URL');
  if (configured.isNotEmpty) return Uri.parse(configured);
  final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
  return Uri.parse('http://$host:8080');
}
