import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

import '../errors.dart';
import '../result.dart';

@immutable
final class AscentTitle {
  const AscentTitle._(this.text);

  static const minLength = 3;

  final String text;

  static Result<AscentTitle> parse(String input) {
    final text = input.trim();
    final length = text.characters.length;
    if (length < minLength) return Failure(TitleTooShort(length));
    return Success(AscentTitle._(text));
  }

  @override
  bool operator ==(Object other) => other is AscentTitle && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'AscentTitle("$text")';
}