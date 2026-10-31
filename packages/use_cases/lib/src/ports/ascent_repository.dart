

import 'package:domain/domain.dart';

abstract interface class AscentRepository {
  Future<List<Mountain>> loadMountains();

  Future<List<Peak>> loadPeaks();

  Future<List<Ascent>> loadAscents();

  Future<Ascent?> find(AscentId id);

  Future<Ascent> replace(Ascent ascent);

  Future<Ascent> add(Ascent ascent);
}