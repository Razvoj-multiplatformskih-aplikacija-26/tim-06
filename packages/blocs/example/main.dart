
import 'package:blocs/src/ascents/ascents_bloc.dart';
import 'package:blocs/src/ascents/ascents_event.dart';
import 'package:blocs/src/ascents/ascents_state.dart';
import 'package:domain/domain.dart';
import 'package:fake_data/fake_data.dart';

Future<void> main() async {
  final repository = FakeAscentRepository(Duration.zero);
  final bloc = AscentsBloc(repository: repository, currentUser: moderator);

  print('--- Pocetno stanje ---');
  print(bloc.state);

  bloc.add(const AscentsRequested());
  await Future<void>.delayed(const Duration(milliseconds: 50));
  print('\n--- Posle ucitavanja ---');
  print(bloc.state.runtimeType);
  if (bloc.state is AscentsLoaded) {
    final loaded = bloc.state as AscentsLoaded;
    print('Broj staza: ${loaded.ascents.length}');
  }

  print('\n--- Moderator pokusava da objavi stazu koja NIJE potvrdjena ---');
  bloc.add(const AscentPublished(AscentId('a-3')));
  await Future<void>.delayed(const Duration(milliseconds: 50));
  if (bloc.state is AscentsLoaded) {
    final loaded = bloc.state as AscentsLoaded;
    print('Greska: ${loaded.lastError}');
  }

  print('\n--- Moderator objavljuje POTVRDJENU stazu (a-1) ---');
  bloc.add(const AscentPublished(AscentId('a-1')));
  await Future<void>.delayed(const Duration(milliseconds: 50));
  if (bloc.state is AscentsLoaded) {
    final loaded = bloc.state as AscentsLoaded;
    final a1 = loaded.ascents.firstWhere((a) => a.id == const AscentId('a-1'));
    print('Status a-1: ${a1.status}');
  }

  await bloc.close();
}