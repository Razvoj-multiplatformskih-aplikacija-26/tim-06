import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import 'dependencies.dart';
import 'router.dart';

class StazeBackofficeApp extends StatefulWidget {
  const StazeBackofficeApp({super.key, required this.dependencies});

  final BackofficeDependencies dependencies;

  @override
  State<StazeBackofficeApp> createState() => _StazeBackofficeAppState();
}

class _StazeBackofficeAppState extends State<StazeBackofficeApp> {
  late final SessionBloc _session = SessionBloc(
    restoreSession: widget.dependencies.restoreSession,
    logOut: widget.dependencies.logOut,
    // Backoffice je za moderatore. Planinar se prijavi ispravno, ali ovde ne ulazi,
    // i to mu ekran kaze recenicom umesto praznim spiskom.
    admits: AccessPolicy.usesBackoffice,
    expirations: widget.dependencies.sessionExpirations,
  )..add(const SessionRestoreRequested());

  @override
  void dispose() {
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = widget.dependencies;
    return RepositoryProvider.value(
      value: dependencies,
      child: BlocProvider.value(
        value: _session,
        child: SessionGate(
          title: 'Staze Backoffice',
          subtitle: 'Pregled i odluka o stazama koje su planinari potvrdili.',
          roleNotAllowedMessage: 'Backoffice je za moderatore. Planinari koriste mobilnu aplikaciju.',
          logIn: dependencies.logIn,
          onSignedIn: (user) => _session.add(SessionStarted(user)),
          theme: ThemeData(colorSchemeSeed: const Color(0xFF2F6B4F), useMaterial3: true),
          darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFF2F6B4F),
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          builder: (context, user) => _SignedIn(user: user, dependencies: dependencies),
        ),
      ),
    );
  }
}

class _SignedIn extends StatefulWidget {
  const _SignedIn({required this.user, required this.dependencies});

  final User user;
  final BackofficeDependencies dependencies;

  @override
  State<_SignedIn> createState() => _SignedInState();
}

class _SignedInState extends State<_SignedIn> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = widget.dependencies;
    return RepositoryProvider.value(
      value: widget.user,
      child: BlocProvider(
        create: (_) => AscentsBloc(
          repository: dependencies.ascents,
          currentUser: widget.user,
          clock: dependencies.clock,
        )..add(const AscentsRequested()),
        child: MaterialApp.router(
          title: 'Staze Backoffice',
          theme: ThemeData(colorSchemeSeed: const Color(0xFF2F6B4F), useMaterial3: true),
          darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFF2F6B4F),
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          routerConfig: _router,
        ),
      ),
    );
  }
}
