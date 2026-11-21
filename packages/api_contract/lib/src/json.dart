
Map<String, Object?> jsonObject(Object? value) => switch (value) {
  final Map<String, Object?> object => object,
  _ => throw FormatException('Ocekivan je JSON objekat', value),
};

List<Map<String, Object?>> jsonObjects(Map<String, Object?> json, String key) => switch (json[key]) {
  final List<Object?> list => [for (final item in list) jsonObject(item)],
  _ => throw FormatException('Polje "$key" treba da bude lista', json),
};

String jsonString(Map<String, Object?> json, String key) => switch (json[key]) {
  final String value => value,
  _ => throw FormatException('Polje "$key" treba da bude tekst', json),
};

String? jsonOptionalString(Map<String, Object?> json, String key) => switch (json[key]) {
  null => null,
  final String value => value,
  _ => throw FormatException('Polje "$key" treba da bude tekst', json),
};

int jsonInt(Map<String, Object?> json, String key) => switch (json[key]) {
  final int value => value,
  _ => throw FormatException('Polje "$key" treba da bude ceo broj', json),
};

double jsonDouble(Map<String, Object?> json, String key) => switch (json[key]) {
  final num value => value.toDouble(),
  _ => throw FormatException('Polje "$key" treba da bude broj', json),
};

double? jsonOptionalDouble(Map<String, Object?> json, String key) => switch (json[key]) {
  null => null,
  final num value => value.toDouble(),
  _ => throw FormatException('Polje "$key" treba da bude broj', json),
};

num? jsonOptionalNum(Map<String, Object?> json, String key) => switch (json[key]) {
  null => null,
  final num value => value,
  _ => throw FormatException('Polje "$key" treba da bude broj', json),
};

List<String> jsonStrings(Map<String, Object?> json, String key) => switch (json[key]) {
  null => const <String>[],
  final List<Object?> list => [
    for (final item in list)
      if (item is String) item else throw FormatException('Polje "$key" treba da bude lista teksta', json),
  ],
  _ => throw FormatException('Polje "$key" treba da bude lista teksta', json),
};

DateTime jsonInstant(Map<String, Object?> json, String key) => _instant(jsonString(json, key), key);

DateTime? jsonOptionalInstant(Map<String, Object?> json, String key) => switch (jsonOptionalString(json, key)) {
  null => null,
  final String value => _instant(value, key),
};

DateTime _instant(String value, String key) {
  final parsed = DateTime.parse(value);
  if (!parsed.isUtc) {
    throw FormatException('Polje "$key" treba da ima vremensku zonu, na primer 2026-11-21T17:00:00Z', value);
  }
  return parsed;
}

String instantToJson(DateTime instant) => instant.toUtc().toIso8601String();
