import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';

import 'screens/ascent_detail_screen.dart';
import 'screens/home_shell.dart';
import 'screens/new_ascent_screen.dart';
import 'screens/route_progress_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeShell()),
      GoRoute(
        path: '/ascent/:id',
        builder: (context, state) => AscentDetailScreen(ascentId: AscentId(state.pathParameters['id']!)),
        routes: [
          GoRoute(
            path: 'route',
            builder: (context, state) => RouteProgressScreen(ascentId: AscentId(state.pathParameters['id']!)),
          ),
        ],
      ),
      GoRoute(path: '/new-ascent', builder: (context, state) => const NewAscentScreen()),
    ],
  );
}
