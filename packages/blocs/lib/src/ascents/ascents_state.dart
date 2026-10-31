

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

sealed class AscentsState extends Equatable {
  const AscentsState();

  @override
  List<Object?> get props => const [];
}

final class AscentsLoading extends AscentsState {
  const AscentsLoading();
}

final class AscentsFailure extends AscentsState {
  const AscentsFailure();
}

final class AscentsEmpty extends AscentsState {
  const AscentsEmpty();
}

final class AscentsLoaded extends AscentsState {
  final List<Ascent> ascents;
  final List<Peak> peaks;
  final List<Mountain> mountains;
  final DomainError? lastError;


  const AscentsLoaded(this.ascents, this.peaks, this.mountains, [this.lastError]);

  Peak? peakOf(Ascent ascent) {
    for (final peak in peaks) {
      if (peak.id == ascent.peakId) return peak;
    }
    return null;
  }

  Mountain? mountainOf(Peak peak) {
    for (final mountain in mountains) {
      if (mountain.id == peak.mountainId) return mountain;
    }
    return null;
  }

  AscentsLoaded copyWith({List<Ascent>? ascents, DomainError? lastError, bool clearError = false}) {
    return AscentsLoaded(
      ascents ?? this.ascents,
      peaks,
      mountains,
      clearError ? null : (lastError ?? this.lastError),
    );
  }

  @override
  List<Object?> get props => [ascents, peaks, mountains, lastError];
}
