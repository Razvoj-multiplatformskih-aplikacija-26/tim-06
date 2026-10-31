

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

sealed class AscentsEvent extends Equatable {
  const AscentsEvent();

  @override
  List<Object?> get props => const [];
}

final class AscentsRequested extends AscentsEvent {
  const AscentsRequested();
}

final class AscentErrorCleared extends AscentsEvent {
  const AscentErrorCleared();
}

final class AscentSubmitted extends AscentsEvent {

  final AscentId id;
  const AscentSubmitted(this.id);

  @override
  List<Object?> get props => [id.value];
}

final class AscentConfirmed extends AscentsEvent {
  final AscentId id;
  const AscentConfirmed(this.id);

  @override
  List<Object?> get props => [id.value];
}

final class AscentPublished extends AscentsEvent {
  final AscentId id;
  const AscentPublished(this.id);

  @override
  List<Object?> get props => [id.value];
}

final class AscentRejected extends AscentsEvent {
  final AscentId id;
  final String reason;
  const AscentRejected(this.id, this.reason);

  @override
  List<Object?> get props => [id.value, reason];
}

final class AscentArchived extends AscentsEvent {
  final AscentId id;
  const AscentArchived(this.id);

  @override
  List<Object?> get props => [id.value];
}
