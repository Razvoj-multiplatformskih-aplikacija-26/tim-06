import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

sealed class AscentsState extends Equatable {
  const AscentsState();

  @override
  List<Object?> get props => const [];
}

final class AscentsLoading extends AscentsState {
  const AscentsLoading();
}

final class AscentsFailure extends AscentsState {
  const AscentsFailure([this.failure = RepositoryFailure.unavailable]);

  final RepositoryFailure failure;

  @override
  List<Object?> get props => [failure];
}

final class AscentsEmpty extends AscentsState {
  const AscentsEmpty();
}

final class AscentsLoaded extends AscentsState {
  const AscentsLoaded(this.ascents, this.peaks, this.mountains, this.users, [this.lastError]);

  final List<Ascent> ascents;
  final List<Peak> peaks;
  final List<Mountain> mountains;
  final List<User> users;

  final DomainError? lastError;

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

  String nameOf(UserId id) {
    for (final user in users) {
      if (user.id == id) return user.username;
    }
    return id.value;
  }

  Map<UserId, String> get names => {for (final user in users) user.id: user.username};

  AscentsLoaded copyWith({List<Ascent>? ascents, DomainError? lastError, bool clearError = false}) {
    return AscentsLoaded(
      ascents ?? this.ascents,
      peaks,
      mountains,
      users,
      clearError ? null : (lastError ?? this.lastError),
    );
  }

  @override
  List<Object?> get props => [ascents, peaks, mountains, users, lastError];
}