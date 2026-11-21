import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_text/ui_text.dart';
import 'package:use_cases/use_cases.dart' show LogIn;

/// Jedan ekran za prijavu, isti u mobilnoj aplikaciji i u backoffice-u.
///
/// Razlikuje ih samo `roleNotAllowedMessage`: recenica koju vidi onaj ko se
/// prijavio u pogresnu aplikaciju. Sam uslov nije ovde nego u domenu, u
/// `AccessPolicy`, pa isto pravilo vazi i na serveru.
class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.title,
    required this.logIn,
    required this.onSignedIn,
    required this.roleNotAllowedMessage,
    this.subtitle,
    this.reason,
    this.appBar,
  });

  final String title;
  final String? subtitle;
  final LogIn logIn;
  final void Function(User user) onSignedIn;
  final String roleNotAllowedMessage;
  final SignOutReason? reason;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginFormBloc(logIn: logIn),
      child: BlocListener<LoginFormBloc, LoginFormState>(
        listener: (context, state) {
          if (state case LoginSucceeded(:final user)) onSignedIn(user);
        },
        child: Scaffold(
          appBar: appBar,
          body: _LoginForm(
            title: title,
            subtitle: subtitle,
            reason: reason,
            roleNotAllowedMessage: roleNotAllowedMessage,
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.title, required this.roleNotAllowedMessage, this.subtitle, this.reason});

  final String title;
  final String? subtitle;
  final String roleNotAllowedMessage;
  final SignOutReason? reason;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() =>
      context.read<LoginFormBloc>().add(LoginSubmitted(username: _username.text, password: _password.text));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<LoginFormBloc>().state;
    final busy = state is LoginSubmitting;
    final message = switch (state) {
      LoginRejected() => 'Pogresno korisnicko ime ili lozinka.',
      LoginFailed(:final cause) => failureMessage(cause),
      _ => switch (widget.reason) {
        SignOutReason.roleNotAllowed => widget.roleNotAllowedMessage,
        SignOutReason.expired => sessionExpiredMessage,
        SignOutReason.unreachable => serverUnreachableMessage,
        SignOutReason.loggedOut || null => null,
      },
    };
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.terrain_outlined, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(widget.title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                ),
                if (widget.subtitle case final subtitle?) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 24),
                if (message != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      message,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _username,
                  enabled: !busy,
                  autofillHints: const [AutofillHints.username],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Korisnicko ime'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  enabled: !busy,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(labelText: 'Lozinka'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy ? null : _submit,
                  child: busy
                      ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, semanticsLabel: 'Prijava u toku'),
                  )
                      : const Text('Prijavi se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
