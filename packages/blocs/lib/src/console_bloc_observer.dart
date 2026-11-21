import 'package:bloc/bloc.dart';

final class ConsoleBlocObserver extends BlocObserver {
  const ConsoleBlocObserver(this.write);

  final void Function(String line) write;

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    write('${bloc.runtimeType}: ${transition.event.runtimeType} -> ${transition.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    write('${bloc.runtimeType} greska: $error');
  }
}