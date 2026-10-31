import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'ascents_event.dart';
import 'ascents_state.dart';

class AscentsBloc extends Bloc<AscentsEvent, AscentsState> {

  final AscentRepository _repository;
  final User _currentUser;
  final SubmitAscent _submit;
  final ConfirmAscent _confirm;
  final PublishAscent _publish;
  final RejectAscent _reject;
  final ArchiveAscent _archive;

  AscentsBloc({required AscentRepository repository, required User currentUser, Clock clock = const SystemClock()})
      : _repository = repository,
        _currentUser = currentUser,
        _submit = SubmitAscent(ascents: repository),
        _confirm = ConfirmAscent(ascents: repository, clock: clock),
        _publish = PublishAscent(ascents: repository, clock: clock),
        _reject = RejectAscent(ascents: repository, clock: clock),
        _archive = ArchiveAscent(ascents: repository, clock: clock),
        super(const AscentsLoading()) {
    on<AscentsRequested>(_onRequested);
    on<AscentSubmitted>(_onSubmitted);
    on<AscentConfirmed>(_onConfirmed);
    on<AscentPublished>(_onPublished);
    on<AscentRejected>(_onRejected);
    on<AscentArchived>(_onArchived);
    on<AscentErrorCleared>(_onErrorCleared);
  }

  User get currentUser => _currentUser;

  Future<void> _onRequested(AscentsRequested event, Emitter<AscentsState> emit) async {
    emit(const AscentsLoading());
    try {
      final mountains = await _repository.loadMountains();
      final peaks = await _repository.loadPeaks();
      final ascents = await _repository.loadAscents();
      if (ascents.isEmpty) {
        emit(const AscentsEmpty());
        return;
      }
      emit(AscentsLoaded(ascents, peaks, mountains));
    } on Object {
      emit(const AscentsFailure());
    }
  }

  void _onErrorCleared(AscentErrorCleared event, Emitter<AscentsState> emit) {
    final current = state;
    if (current is AscentsLoaded) emit(current.copyWith(clearError: true));
  }

  Future<void> _run(Emitter<AscentsState> emit, Future<Result<Ascent>> Function() action) async {
    final current = state;
    if (current is! AscentsLoaded) return;

    try {
      final result = await action();
      switch (result) {
        case Failure<Ascent>(:final error):
          emit(current.copyWith(lastError: error));
        case Success<Ascent>(:final value):
          final updated = [
            for (final ascent in current.ascents)
              if (ascent.id == value.id) value else ascent,
          ];
          emit(current.copyWith(ascents: updated, clearError: true));
      }
    } on Object {
      emit(const AscentsFailure());
    }
  }

  Future<void> _onSubmitted(AscentSubmitted event, Emitter<AscentsState> emit) =>
      _run(emit, () => _submit.call(id: event.id, by: _currentUser));

  Future<void> _onConfirmed(AscentConfirmed event, Emitter<AscentsState> emit) =>
      _run(emit, () => _confirm.call(id: event.id, by: _currentUser));

  Future<void> _onPublished(AscentPublished event, Emitter<AscentsState> emit) =>
      _run(emit, () => _publish.call(id: event.id, by: _currentUser));

  Future<void> _onRejected(AscentRejected event, Emitter<AscentsState> emit) =>
      _run(emit, () => _reject.call(id: event.id, by: _currentUser, reason: event.reason));

  Future<void> _onArchived(AscentArchived event, Emitter<AscentsState> emit) =>
      _run(emit, () => _archive.call(id: event.id, by: _currentUser));

}