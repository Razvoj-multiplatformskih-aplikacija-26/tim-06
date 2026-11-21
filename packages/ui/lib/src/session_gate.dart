import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:use_cases/use_cases.dart' show LogIn;

import 'login_screen.dart';
import 'state_views.dart';

/// Kapija ispred aplikacije.
///
/// Tri stanja, i nijedno nije "mozda": dok se ne sazna da li prijava od proslog
/// puta jos vazi, vidi se ucitavanje; ako ne vazi, ekran za prijavu sa razlogom;
/// ako vazi, aplikacija. `ValueKey` na prijavljenom delu znaci da se pri promeni
/// korisnika cela aplikacija gradi iznova, pa nijedan ekran ne ostaje sa tudjim
/// podacima.
class SessionGate extends StatelessWidget {
  const SessionGate({
    super.key,
    required this.title,
    required this.subtitle,
    required this.roleNotAllowedMessage,
    required this.logIn,
    required this.onSignedIn,
    required this.builder,
    required this.theme,
    this.darkTheme,
    this.locale,
    this.localizationsDelegates,
  });

  final String title;
  final String subtitle;
  final String roleNotAllowedMessage;
  final LogIn logIn;
  final void Function(User user) onSignedIn;
  final Widget Function(BuildContext context, User user) builder;
  final ThemeData theme;
  final ThemeData? darkTheme;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<Object?>>? localizationsDelegates;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, session) => switch (session) {
        SessionUnknown() => _shell(key: const ValueKey('session-unknown'), home: const Scaffold(body: LoadingView())),
        SignedOut(:final reason) => _shell(
          key: ValueKey('signed-out ${reason?.name}'),
          home: LoginScreen(
            title: title,
            subtitle: subtitle,
            logIn: logIn,
            reason: reason,
            roleNotAllowedMessage: roleNotAllowedMessage,
            onSignedIn: onSignedIn,
          ),
        ),
        SignedIn(:final user) => KeyedSubtree(key: ValueKey(user.id.value), child: builder(context, user)),
      },
    );
  }

  Widget _shell({Key? key, required Widget home}) => MaterialApp(
    key: key,
    title: title,
    theme: theme,
    darkTheme: darkTheme,
    locale: locale,
    supportedLocales: locale == null ? const [Locale('en')] : [locale!],
    localizationsDelegates: localizationsDelegates,
    home: home,
  );
}
