import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart';

final class AscentStore {
  const AscentStore(this._database);

  final Session _database;

  static const _columns =
      'id, peak_id, author_id, title, description, difficulty, distance_km, waypoints, track, '
      'status, status_by, status_at, reject_reason, created_at';

  Future<bool> isEmpty() async {
    final rows = await _database.execute('SELECT count(*) FROM users');
    return rows.single[0] == 0;
  }

  Future<List<Mountain>> mountains() async {
    final rows = await _database.execute('SELECT id, name, country, lat, lon FROM mountains ORDER BY name');
    return [
      for (final row in rows)
        Mountain(
          MountainId(row[0]! as String),
          row[1]! as String,
          row[2]! as String,
          GeoPoint(_double(row[3]), _double(row[4])),
        ),
    ];
  }

  Future<List<Peak>> peaks() async {
    final rows = await _database.execute(
      'SELECT id, name, mountain_id, altitude_m, lat, lon FROM peaks ORDER BY altitude_m DESC',
    );
    return [
      for (final row in rows)
        Peak(
          PeakId(row[0]! as String),
          row[1]! as String,
          MountainId(row[2]! as String),
          row[3]! as int,
          GeoPoint(_double(row[4]), _double(row[5])),
        ),
    ];
  }

  Future<Peak?> peak(PeakId id) async {
    final rows = await _database.execute(
      Sql.named('SELECT id, name, mountain_id, altitude_m, lat, lon FROM peaks WHERE id = @id'),
      parameters: {'id': id.value},
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    return Peak(
      PeakId(row[0]! as String),
      row[1]! as String,
      MountainId(row[2]! as String),
      row[3]! as int,
      GeoPoint(_double(row[4]), _double(row[5])),
    );
  }

  Future<List<User>> users() async {
    final rows = await _database.execute('SELECT id, username, role FROM users ORDER BY username');
    return [
      for (final row in rows) User(UserId(row[0]! as String), row[1]! as String, Role.values.byName(row[2]! as String)),
    ];
  }

  Future<User?> user(UserId id) async {
    final rows = await _database.execute(
      Sql.named('SELECT id, username, role FROM users WHERE id = @id'),
      parameters: {'id': id.value},
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    return User(UserId(row[0]! as String), row[1]! as String, Role.values.byName(row[2]! as String));
  }

  Future<List<Ascent>> ascents() async {
    final rows = await _database.execute('SELECT $_columns FROM ascents ORDER BY created_at DESC');
    final confirmations = await _allConfirmations();
    return [
      for (final row in rows) _ascent(row.toColumnMap(), confirmations[row[0]! as String] ?? const <UserId>{}),
    ];
  }

  Future<Ascent?> find(AscentId id) async {
    final rows = await _database.execute(
      Sql.named('SELECT $_columns FROM ascents WHERE id = @id'),
      parameters: {'id': id.value},
    );
    if (rows.isEmpty) return null;
    return _ascent(rows.single.toColumnMap(), await confirmationsOf(id));
  }

  Future<Ascent?> findForUpdate(AscentId id) async {
    final rows = await _database.execute(
      Sql.named('SELECT $_columns FROM ascents WHERE id = @id FOR UPDATE'),
      parameters: {'id': id.value},
    );
    if (rows.isEmpty) return null;
    return _ascent(rows.single.toColumnMap(), await confirmationsOf(id));
  }

  Future<Set<UserId>> confirmationsOf(AscentId id) async {
    final rows = await _database.execute(
      Sql.named('SELECT user_id FROM ascent_confirmations WHERE ascent_id = @id'),
      parameters: {'id': id.value},
    );
    return {for (final row in rows) UserId(row[0]! as String)};
  }

  Future<bool> addConfirmation(AscentId id, UserId by, DateTime at) async {
    final result = await _database.execute(
      Sql.named(
        'INSERT INTO ascent_confirmations (ascent_id, user_id, confirmed_at) VALUES (@ascent, @user, @at) '
            'ON CONFLICT DO NOTHING',
      ),
      parameters: {'ascent': id.value, 'user': by.value, 'at': at.toUtc()},
    );
    return result.affectedRows == 1;
  }

  Future<int> countConfirmations(AscentId id) async {
    final rows = await _database.execute(
      Sql.named('SELECT count(*) FROM ascent_confirmations WHERE ascent_id = @id'),
      parameters: {'id': id.value},
    );
    return rows.single[0]! as int;
  }

  Future<void> insert(Ascent ascent) async {
    final columns = _statusColumns(ascent.status);
    await _database.execute(
      Sql.named('''
        INSERT INTO ascents
          (id, peak_id, author_id, title, description, difficulty, distance_km, waypoints, track,
           status, status_by, status_at, reject_reason, created_at)
        VALUES
          (@id, @peak, @author, @title, @description, @difficulty, @distance, @waypoints::jsonb, @track::jsonb,
           @status, @statusBy, @statusAt, @reason, @created)
      '''),
      parameters: {
        'id': ascent.id.value,
        'peak': ascent.peakId.value,
        'author': ascent.authorId.value,
        'title': ascent.title.text,
        'description': ascent.description?.text,
        'difficulty': ascent.difficulty.name,
        'distance': ascent.distanceKm,
        'waypoints': jsonEncode([for (final waypoint in ascent.waypoints) waypoint.toDto().toJson()]),
        'track': jsonEncode([for (final point in ascent.track) point.toDto().toJson()]),
        'status': columns.kind,
        'statusBy': columns.by,
        'statusAt': columns.at,
        'reason': columns.reason,
        'created': ascent.createdAt.toUtc(),
      },
    );
  }

  Future<bool> changeStatusRow(AscentId id, AscentStatus status, {required AscentStatus from}) async {
    final columns = _statusColumns(status);
    final result = await _database.execute(
      Sql.named('''
        UPDATE ascents
        SET status = @status, status_by = @statusBy, status_at = @statusAt, reject_reason = @reason
        WHERE id = @id AND status = @previous
      '''),
      parameters: {
        'id': id.value,
        'status': columns.kind,
        'statusBy': columns.by,
        'statusAt': columns.at,
        'reason': columns.reason,
        'previous': _statusColumns(from).kind,
      },
    );
    return result.affectedRows == 1;
  }

  Future<Map<String, Set<UserId>>> _allConfirmations() async {
    final rows = await _database.execute('SELECT ascent_id, user_id FROM ascent_confirmations');
    final byAscent = <String, Set<UserId>>{};
    for (final row in rows) {
      byAscent.putIfAbsent(row[0]! as String, () => <UserId>{}).add(UserId(row[1]! as String));
    }
    return byAscent;
  }
}

double _double(Object? value) => (value! as num).toDouble();

List<Map<String, Object?>> _jsonList(Object? value) => switch (value) {
  null => const [],
  final String text => [for (final item in jsonDecode(text) as List<Object?>) item! as Map<String, Object?>],
  final List<Object?> list => [for (final item in list) (item! as Map).cast<String, Object?>()],
  _ => throw FormatException('Ocekivana je JSON lista u bazi', value),
};

Ascent _ascent(Map<String, dynamic> row, Set<UserId> confirmedBy) => AscentDto(
  id: row['id'] as String,
  peakId: row['peak_id'] as String,
  authorId: row['author_id'] as String,
  title: row['title'] as String,
  description: row['description'] as String?,
  difficulty: row['difficulty'] as String,
  distanceKm: (row['distance_km'] as num).toDouble(),
  waypoints: [for (final item in _jsonList(row['waypoints'])) WaypointDto.fromJson(item)],
  track: [for (final item in _jsonList(row['track'])) GeoPointDto.fromJson(item)],
  status: _statusDto(row, confirmedBy),
  createdAt: (row['created_at'] as DateTime).toUtc(),
).toDomain();

AscentStatusDto _statusDto(Map<String, dynamic> row, Set<UserId> confirmedBy) {
  final at = (row['status_at'] as DateTime?)?.toUtc();
  final by = row['status_by'] as String?;
  final ids = [for (final id in confirmedBy) id.value];
  return switch (row['status'] as String) {
    AscentStatusDto.proposed => AscentStatusDto(kind: AscentStatusDto.proposed, confirmedBy: ids),
    AscentStatusDto.confirmed => AscentStatusDto(kind: AscentStatusDto.confirmed, confirmedBy: ids, at: at),
    AscentStatusDto.published => AscentStatusDto(kind: AscentStatusDto.published, by: by, at: at),
    AscentStatusDto.rejected => AscentStatusDto(
      kind: AscentStatusDto.rejected,
      by: by,
      at: at,
      reason: row['reject_reason'] as String? ?? '',
    ),
    AscentStatusDto.archived => AscentStatusDto(kind: AscentStatusDto.archived, by: by, at: at),
    _ => const AscentStatusDto(kind: AscentStatusDto.draft),
  };
}

({String kind, String? by, DateTime? at, String? reason}) _statusColumns(AscentStatus status) => switch (status) {
  Draft() => (kind: AscentStatusDto.draft, by: null, at: null, reason: null),
  Proposed() => (kind: AscentStatusDto.proposed, by: null, at: null, reason: null),
  Confirmed(:final at) => (kind: AscentStatusDto.confirmed, by: null, at: at, reason: null),
  Published(:final publishedBy, :final at) => (
  kind: AscentStatusDto.published,
  by: publishedBy.value,
  at: at,
  reason: null,
  ),
  Rejected(:final reason, :final rejectedBy, :final at) => (
  kind: AscentStatusDto.rejected,
  by: rejectedBy.value,
  at: at,
  reason: reason,
  ),
  Archived(:final archivedBy, :final at) => (
  kind: AscentStatusDto.archived,
  by: archivedBy.value,
  at: at,
  reason: null,
  ),
};
