import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'ascents_event.dart';
import 'ascents_state.dart';

class AscentsBloc extends Bloc<AscentsEvent, AscentsState> {

  final User _currentUser;
  final GetAscents _getAscents;
  final CreateAscentUseCase _create;
  final SubmitAscent _submit;
  final ConfirmAscent _confirm;
  final PublishAscent _publish;
  final RejectAscent _reject;
  final ArchiveAscent _archive;

  AscentsBloc({
    required User currentUser,
    required GetAscents getAscents,
    required CreateAscentUseCase createAscent,
    required SubmitAscent submitAscent,
    required ConfirmAscent confirmAscent,
    required PublishAscent publishAscent,
    required RejectAscent rejectAscent,
    required ArchiveAscent archiveAscent,
  }) : _currentUser = currentUser,
        _getAscents = getAscents,
        _create = createAscent,
        _submit = submitAscent,
        _confirm = confirmAscent,
        _publish = publishAscent,
        _reject = rejectAscent,
        _archive = archiveAscent,
        super(const AscentsLoading()) {
    on<AscentsRequested>(_onRequested);
    on<AscentCreated>(_onCreated);
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
      final overview = await _getAscents.call();
      if (overview.ascents.isEmpty) {
        emit(const AscentsEmpty());
        return;
      }
      emit(AscentsLoaded(overview.ascents, overview.peaks, overview.mountains));
    } on Object {
      emit(const AscentsFailure());
    }
  }

  void _onErrorCleared(AscentErrorCleared event, Emitter<AscentsState> emit) {
    final current = state;
    if (current is AscentsLoaded) emit(current.copyWith(clearError: true));
  }

  Future<void> _onCreated(AscentCreated event, Emitter<AscentsState> emit) async {
    final current = state;
    if (current is! AscentsLoaded) return;

    try {
      final result = await _create.call(
        id: event.id,
        peakId: event.peakId,
        author: _currentUser,
        title: event.title,
        difficulty: event.difficulty,
        distanceKm: event.distanceKm,
        waypoints: event.waypoints,
        description: event.description,
      );
      switch (result) {
        case Failure<Ascent>(:final error):
          emit(current.copyWith(lastError: error));
        case Success<Ascent>(:final value):
          var created = value;
          if (event.submitImmediately) {
            final submitted = await _submit.call(id: created.id, by: _currentUser);
            if (submitted case Success<Ascent>(:final value)) created = value;
          }
          emit(current.copyWith(ascents: [...current.ascents, created], clearError: true));
      }
    } on Object {
      emit(const AscentsFailure());
    }
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