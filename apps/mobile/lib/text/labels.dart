
import 'package:domain/domain.dart';

String statusLabel(AscentStatus status) => switch (status) {
  Draft() => 'Priprema',
  Proposed() => 'Predlozena',
  Confirmed() => 'Potvrdjena',
  Published() => 'Objavljena',
  Rejected() => 'Odbijena',
  Archived() => 'Arhivirana',
};

String difficultyLabel(Difficulty difficulty) => switch (difficulty) {
  Difficulty.easy => 'Laka',
  Difficulty.moderate => 'Srednja',
  Difficulty.hard => 'Teska',
};

String plural(int count, String one, String few, String many) {
  final lastDigit = count % 10;
  final lastTwo = count % 100;
  if (lastDigit == 1 && lastTwo != 11) return one;
  if (lastDigit >= 2 && lastDigit <= 4 && (lastTwo < 12 || lastTwo > 14)) return few;
  return many;
}

int confirmationCount(AscentStatus status) => switch (status) {
  Proposed(:final confirmedBy) => confirmedBy.length,
  Confirmed(:final confirmedBy) => confirmedBy.length,
  Draft() || Published() || Rejected() || Archived() => 0,
};

String kilometers(double km) => '${formatNumber(km)} km';

String duration(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return '$rest min';
  if (rest == 0) return '$hours h';
  return '$hours h $rest min';
}

String formatNumber(double value) {
  final rounded = (value * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) return rounded.round().toString();
  return rounded.toStringAsFixed(1).replaceAll('.', ',');
}