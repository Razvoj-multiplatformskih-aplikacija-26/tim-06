import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'seed_data.dart';

class FakeAscentRepository implements AscentRepository {
  FakeAscentRepository([this.delay = const Duration(milliseconds: 600)]);

  final List<Mountain> _mountains = List<Mountain>.of(seedMountains);
  final List<Peak> _peaks = List<Peak>.of(seedPeaks);
  final List<User> _users = List<User>.of(seedUsers);
  final List<Ascent> _ascents = List<Ascent>.of(seedAscents());

  final Duration delay;

  bool failNextRequest = false;

  Future<void> _wait() async {
    await Future<void>.delayed(delay);
    if (failNextRequest) {
      failNextRequest = false;
      throw const RepositoryException(
        'namerna greska za demonstraciju',
        failure: RepositoryFailure.unreachable,
      );
    }
  }

  @override
  Future<List<Mountain>> loadMountains() async {
    await _wait();
    return List<Mountain>.unmodifiable(_mountains);
  }

  @override
  Future<List<Peak>> loadPeaks() async {
    await _wait();
    return List<Peak>.unmodifiable(_peaks);
  }

  @override
  Future<List<User>> loadUsers() async {
    await _wait();
    return List<User>.unmodifiable(_users);
  }

  @override
  Future<List<Ascent>> loadAscents() async {
    await _wait();
    return List<Ascent>.unmodifiable(_ascents);
  }

  @override
  Future<Ascent?> find(AscentId id) async {
    await _wait();
    for (final ascent in _ascents) {
      if (ascent.id == id) return ascent;
    }
    return null;
  }

  @override
  Future<Result<Ascent>> add(Ascent ascent) async {
    await _wait();
    _ascents.add(ascent);
    return Success(ascent);
  }

  @override
  Future<Result<Ascent>> replace(Ascent ascent, {required AscentStatus from}) async {
    await _wait();
    for (var i = 0; i < _ascents.length; i++) {
      if (_ascents[i].id != ascent.id) continue;
      final current = _ascents[i];
      if (current.status != from) return Failure(InvalidTransition(current.status, ascent.status));
      _ascents[i] = ascent;
      return Success(ascent);
    }
    return const Failure(NotFound());
  }
}