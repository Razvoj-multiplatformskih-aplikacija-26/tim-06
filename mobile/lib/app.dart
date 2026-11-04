import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dependencies.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class StazeApp extends StatefulWidget {
  const StazeApp({super.key});

  @override
  State<StazeApp> createState() => _StazeAppState();
}

class _StazeAppState extends State<StazeApp> {
  final _dependencies = MobileDependencies.fake();
  late final _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
        value: _dependencies,
        child: BlocProvider(
          create: (context) => AscentsBloc(
            currentUser: _dependencies.user,
            getAscents: _dependencies.getAscents,
            createAscent: _dependencies.createAscent,
            submitAscent: _dependencies.submitAscent,
            confirmAscent: _dependencies.confirmAscent,
            publishAscent: _dependencies.publishAscent,
            rejectAscent: _dependencies.rejectAscent,
            archiveAscent: _dependencies.archiveAscent,
          )..add(const AscentsRequested()),
          child: MaterialApp.router(
            title: 'Staze',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.system,
            routerConfig: _router,
          ),
        ),
    );
  }
}
