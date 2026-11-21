import 'ascent_dto.dart';
import 'json.dart';

final class ProblemDto {
  const ProblemDto({
    required this.status,
    required this.code,
    required this.title,
    this.value,
    this.min,
    this.max,
    this.from,
    this.to,
  });

  static const mediaType = 'application/problem+json';

  static String typeOf(String code) => 'tag:raf.rs,2026:staze/problem/$code';

  final int status;
  final String code;
  final String title;
  final num? value;
  final num? min;
  final num? max;
  final AscentStatusDto? from;
  final AscentStatusDto? to;

  Map<String, Object?> toJson() => {
    'type': typeOf(code),
    'title': title,
    'status': status,
    'code': code,
    if (value != null) 'value': value,
    if (min != null) 'min': min,
    if (max != null) 'max': max,
    if (from case final from?) 'from': from.toJson(),
    if (to case final to?) 'to': to.toJson(),
  };

  factory ProblemDto.fromJson(Map<String, Object?> json) => ProblemDto(
    status: jsonInt(json, 'status'),
    code: jsonString(json, 'code'),
    title: jsonOptionalString(json, 'title') ?? '',
    value: jsonOptionalNum(json, 'value'),
    min: jsonOptionalNum(json, 'min'),
    max: jsonOptionalNum(json, 'max'),
    from: json['from'] == null ? null : AscentStatusDto.fromJson(jsonObject(json['from'])),
    to: json['to'] == null ? null : AscentStatusDto.fromJson(jsonObject(json['to'])),
  );
}
