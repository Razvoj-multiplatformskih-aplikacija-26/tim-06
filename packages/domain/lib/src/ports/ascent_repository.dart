
import '../../domain.dart';

abstract interface class AscentRepository{
  Future<List<Mountain>> loadMountains();

  Future<List<Peak>> loadPeaks();
  Future<List<Ascent>> loadAscents();

  Future<Ascent> replace(Ascent ascent);
  Future<Ascent> add(Ascent ascent);
}

class RepositoryFailure implements Exception{

  final Object? cause;

  const RepositoryFailure([this.cause]);

  @override
  String toString() => 'RepositoryFailure($cause)';
}