
import 'package:domain/domain.dart';

import '../fake_data.dart';

class FakeAscentRepository implements AscentRepository {

  final List<Mountain> _mountains = List<Mountain>.of(seedMountains);
  final List<Peak> _peaks = List<Peak>.of(seedPeaks);
  final List<Ascent> _ascents = List<Ascent>.of(seedAscents());

  final Duration delay;

  bool failNextRequest = false;

  FakeAscentRepository([this.delay = const Duration(milliseconds: 600)]);


  Future<void> _wait() async {
    await Future<void>.delayed(delay);
    if (failNextRequest) {
      failNextRequest = false;
      throw const RepositoryFailure('namerna greška za demonstraciju');
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
  Future<List<Ascent>> loadAscents() async {
    await _wait();
    return List<Ascent>.unmodifiable(_ascents);
  }

  @override
  Future<Ascent> replace(Ascent ascent) async {
    await _wait();
    for (var i = 0; i < _ascents.length; i++) {
      if (_ascents[i].id == ascent.id) {
        _ascents[i] = ascent;
        return ascent;
      }
    }
    throw const RepositoryFailure('staza nije pronađena');
  }


  @override
  Future<Ascent> add(Ascent ascent) async {
    await _wait();
    _ascents.add(ascent);
    return ascent;
  }
}