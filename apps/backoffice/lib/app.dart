import 'package:backoffice/router.dart';
import 'package:backoffice/theme/app_theme.dart';
import 'package:blocs/blocs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dependencies.dart';

class BackofficeApp extends StatefulWidget {
  const BackofficeApp({super.key});

  @override
  State<BackofficeApp> createState() => _BackofficeAppState();
}

class _BackofficeAppState extends State<BackofficeApp> {
  final _dependencies = BackofficeDependencies.fake();
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
          repository: _dependencies.ascents,
          currentUser: _dependencies.user,
          clock: _dependencies.clock,
        )..add(const AscentsRequested()),
        child: MaterialApp.router(
          title: 'Staze · backoffice',
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