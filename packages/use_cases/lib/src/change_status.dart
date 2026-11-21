import 'package:domain/domain.dart';

import 'ports/ascent_repository.dart';

Future<Result<Ascent>> changeStatus(
    AscentRepository ascents,
    AscentId id, {
      required Result<Ascent> Function(Ascent current) change,
    }) async {
  final current = await ascents.find(id);
  if (current == null) return const Failure(NotFound());

  final result = change(current);
  return switch (result) {
    Failure<Ascent>() => result,
    Success<Ascent>(:final value) => ascents.replace(value, from: current.status),
  };
}