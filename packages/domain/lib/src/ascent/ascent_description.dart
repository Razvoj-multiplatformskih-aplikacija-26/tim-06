import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

import '../errors.dart';
import '../result.dart';

@immutable
final class AscentDescription {
  final String text;
  static const maxLength = 200;

  const AscentDescription._(this.text);


  int get length => text.characters.length;

  bool get isEmpty => text.isEmpty;

  static Result<AscentDescription> parse(String input) {
    final text = input.trim();
    final length = text.characters.length;
    if(length > maxLength) return Failure(DescriptionTooLong(length));
    return Success(AscentDescription._(text));
  }

  @override
  bool operator ==(Object other) => other is AscentDescription && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'AscentDescription("$text")';
}