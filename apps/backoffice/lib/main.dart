import 'package:api_client/api_client.dart';
import 'package:blocs/blocs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'data/secure_token_store.dart';
import 'dependencies.dart';

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) Bloc.observer = ConsoleBlocObserver(debugPrint);

  // U pregledacu prijavu drzi kolacic koji JavaScript ne vidi, pa aplikacija
  // nema sta da cuva; na desktopu token ide u bezbedno skladiste platforme.
  final dependencies = BackofficeDependencies.server(
    baseUri: Uri.parse(const String.fromEnvironment('SERVER_URL', defaultValue: 'http://localhost:8080')),
    tokens: kIsWeb ? MemoryTokenStore() : const SecureTokenStore(),
  );

  runApp(StazeBackofficeApp(dependencies: dependencies));
}
