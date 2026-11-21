import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart' hide Result;
import 'package:use_cases/use_cases.dart';

import 'ascent_store.dart';

const _foreignKeyViolation = '23503';

final class PostgresAscents implements AscentRepository {
  const PostgresAscents(this._database, {required this.clock});

  final Pool<void> _database;
  final Clock clock;

  AscentStore get _store => AscentStore(_database);

  @override
  Future<List<Mountain>> loadMountains() => _store.mountains();

  @override
  Future<List<Peak>> loadPeaks() => _store.peaks();

  @override
  Future<List<User>> loadUsers() => _store.users();

  @override
  Future<List<Ascent>> loadAscents() => _store.ascents();

  @override
  Future<Ascent?> find(AscentId id) => _store.find(id);

  Future<Peak?> peak(PeakId id) => _store.peak(id);

  Future<User?> user(UserId id) => _store.user(id);

  @override
  Future<Result<Ascent>> add(Ascent ascent) async {
    try {
      await _store.insert(ascent);
    } on ServerException catch (error) {
      if (error.code == _foreignKeyViolation) return const Failure(NotFound());
      rethrow;
    }
    return Success(ascent);
  }

  @override
  Future<Result<Ascent>> replace(Ascent ascent, {required AscentStatus from}) => _database.runTx((transaction) async {
    final store = AscentStore(transaction);

    final current = await store.findForUpdate(ascent.id);
    if (current == null) return const Failure<Ascent>(NotFound());
    if (current.status.runtimeType != from.runtimeType) {
      return Failure<Ascent>(InvalidTransition(current.status, ascent.status));
    }

    final added = _confirmers(ascent.status).difference(_confirmers(from));
    if (added.isEmpty) return _plainChange(store, ascent, current: current);
    return _confirmation(store, ascent.id, added: added, current: current);
  });

  Future<Result<Ascent>> _plainChange(AscentStore store, Ascent ascent, {required Ascent current}) async {
    if (!await store.changeStatusRow(ascent.id, ascent.status, from: current.status)) {
      return Failure<Ascent>(InvalidTransition(current.status, ascent.status));
    }
    return Success<Ascent>((await store.find(ascent.id))!);
  }

  Future<Result<Ascent>> _confirmation(
      AscentStore store,
      AscentId id, {
        required Set<UserId> added,
        required Ascent current,
      }) async {
    for (final by in added) {
      if (!await store.addConfirmation(id, by, clock.now())) return const Failure<Ascent>(AlreadyConfirmed());
    }
    final confirmedBy = await store.confirmationsOf(id);
    final next = confirmedBy.length >= requiredConfirmations
        ? Confirmed(confirmedBy, clock.now())
        : Proposed(confirmedBy);
    if (!await store.changeStatusRow(id, next, from: current.status)) {
      return Failure<Ascent>(InvalidTransition(current.status, next));
    }
    return Success<Ascent>((await store.find(id))!);
  }
}

Set<UserId> _confirmers(AscentStatus status) => switch (status) {
  Proposed(:final confirmedBy) => confirmedBy,
  Confirmed(:final confirmedBy) => confirmedBy,
  Draft() || Published() || Rejected() || Archived() => const <UserId>{},
};