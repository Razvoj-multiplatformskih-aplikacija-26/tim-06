
import 'package:backoffice/screens/ascents_screen.dart';
import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          final selected = state.uri.queryParameters['ascent'];
          return AscentsScreen(initialSelectedId: selected == null ? null : AscentId(selected));
        },
      ),
    ],
  );
}