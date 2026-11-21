

import 'package:domain/domain.dart';

abstract interface class AscentRepository {
  Future<List<Mountain>> loadMountains();

  Future<List<Peak>> loadPeaks();

  Future<List<User>> loadUsers();

  Future<List<Ascent>> loadAscents();

  Future<Ascent?> find(AscentId id);

  Future<Result<Ascent>> add(Ascent ascent);

  Future<Result<Ascent>> replace(Ascent ascent, {required AscentStatus from});
}
