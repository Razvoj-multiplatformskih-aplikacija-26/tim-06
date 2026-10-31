import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';

import 'ascents_event.dart';
import 'ascents_state.dart';

class AscentsBloc extends Bloc<AscentsEvent, AscentsState> {

  final AscentRepository _repository;
  final User _currentUser;
  final DateTime Function() _now;

  AscentsBloc({required AscentRepository repository, required User currentUser, DateTime Function()? now})
      : _repository = repository,
        _currentUser = currentUser,
        _now = now ?? DateTime.now,
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

  Future<void> _apply(AscentId id, Emitter<AscentsState> emit, Result<Ascent> Function(Ascent ascent) change) async {
    final current = state;
    if (current is! AscentsLoaded) return;

    Ascent? target;
    for (final ascent in current.ascents) {
      if (ascent.id == id) target = ascent;
    }
    if (target == null) {
      emit(current.copyWith(lastError: const NotFound()));
      return;
    }

    final result = change(target);
    switch (result) {
      case Failure<Ascent>(:final error):
        emit(current.copyWith(lastError: error));
      case Success<Ascent>(:final value):
        try {
          final saved = await _repository.replace(value);
          final updated = [
            for (final ascent in current.ascents)
              if (ascent.id == saved.id) saved else ascent,
          ];
          emit(current.copyWith(ascents: updated, clearError: true));
        } on Object {
          emit(const AscentsFailure());
        }
    }
  }

  Future<void> _onSubmitted(AscentSubmitted event, Emitter<AscentsState> emit) {
    return _apply(event.id, emit, (ascent) => submitAscent(ascent, by: _currentUser));
  }

  Future<void> _onConfirmed(AscentConfirmed event, Emitter<AscentsState> emit) {
    return _apply(event.id, emit, (ascent) => confirmAscent(ascent, by: _currentUser, now: _now()));
  }

  Future<void> _onPublished(AscentPublished event, Emitter<AscentsState> emit) {
    return _apply(event.id, emit, (ascent) => publishAscent(ascent, by: _currentUser, now: _now()));
  }

  Future<void> _onRejected(AscentRejected event, Emitter<AscentsState> emit) {
    return _apply(
      event.id,
      emit,
          (ascent) => rejectAscent(ascent, by: _currentUser, now: _now(), reason: event.reason),
    );
  }

  Future<void> _onArchived(AscentArchived event, Emitter<AscentsState> emit) {
    return _apply(event.id, emit, (ascent) => archiveAscent(ascent, by: _currentUser, now: _now()));
  }

}