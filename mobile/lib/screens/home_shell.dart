import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../text/domain_errors.dart';
import 'ascents_tab.dart';
import 'confirmations_tab.dart';
import 'my_ascents_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.terrain, label: 'Staze'),
    (icon: Icons.check_circle_outline, label: 'Potvrde'),
    (icon: Icons.person_outline, label: 'Moje'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AscentsBloc, AscentsState>(
      listenWhen: (previous, current) => current is AscentsLoaded && current.lastError != null,
      listener: (context, state) {
        final error = (state as AscentsLoaded).lastError;
        if (error == null) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(messageFor(error))));
        context.read<AscentsBloc>().add(const AscentErrorCleared());
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [AscentsTab(), ConfirmationsTab(), MyAscentsTab()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            for (final tab in _tabs) NavigationDestination(icon: Icon(tab.icon), label: tab.label),
          ],
        ),
      ),
    );
  }
}
