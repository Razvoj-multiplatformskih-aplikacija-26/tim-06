import 'dart:async';
import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:use_cases/use_cases.dart';

import 'platform_client.dart';
import 'token_store.dart';

/// Tri ishoda jednog poziva: proslo je, pravilo ga je odbilo, ili server kaze
/// nesto sto ova verzija aplikacije ne razume.
sealed class ApiAnswer {
  const ApiAnswer();
}

final class ApiAccepted extends ApiAnswer {
  const ApiAccepted(this.json);

  final Object? json;
}

final class ApiRejected extends ApiAnswer {
  const ApiRejected(this.error);

  final DomainError error;
}

final class ApiRefused extends ApiAnswer {
  const ApiRefused(this.problem);

  final ProblemDto problem;
}

/// Jedno mesto koje zna kako se razgovara sa serverom: adresa, prijava, rokovi
/// i prevod gresaka. Repozitorijumi iznad njega znaju samo svoje adrese.
final class ApiClient {
  ApiClient({
    required this.baseUri,
    TokenStore? tokens,
    http.Client? httpClient,
    this.keepsSessionInCookie = platformKeepsSessionInCookie,
    this.timeout = const Duration(seconds: 10),
  }) : tokens = tokens ?? MemoryTokenStore(),
        _http = httpClient ?? platformHttpClient();

  final Uri baseUri;
  final TokenStore tokens;
  final bool keepsSessionInCookie;
  final Duration timeout;
  final http.Client _http;
  final _expirations = StreamController<void>.broadcast();

  Stream<void> get expirations => _expirations.stream;

  Future<ApiAnswer> get(String path, {Map<String, String>? query}) => _send('GET', path, query: query);

  Future<ApiAnswer> post(String path, {Map<String, Object?>? body}) => _send('POST', path, body: body);

  Future<ApiAnswer> delete(String path) => _send('DELETE', path);

  Future<ApiAnswer> _send(String method, String path, {Map<String, String>? query, Map<String, Object?>? body}) async {
    final request = http.Request(method, baseUri.replace(path: path, queryParameters: query))
      ..headers['Accept'] = 'application/json';
    if (!keepsSessionInCookie) {
      if (await tokens.read() case final token?) request.headers['Authorization'] = 'Bearer $token';
    }
    if (body != null) {
      request
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);
    }
    final http.Response response;
    try {
      response = await _http.send(request).then(http.Response.fromStream).timeout(timeout);
    } on http.ClientException catch (cause) {
      // Nema mreze ili server ne radi. Ekran ovo prikazuje kao poruku, a ne kao
      // vrtesku koja se nikada ne zaustavi.
      throw RepositoryException('Server nije dostupan', failure: RepositoryFailure.unreachable, cause: cause);
    } on TimeoutException catch (cause) {
      throw RepositoryException('Server ne odgovara', failure: RepositoryFailure.unreachable, cause: cause);
    }
    return _answerOf(response);
  }

  ApiAnswer _answerOf(http.Response response) {
    final status = response.statusCode;
    final json = readJson(() => response.body.isEmpty ? null : jsonDecode(utf8.decode(response.bodyBytes)));
    if (status >= 200 && status < 300) return ApiAccepted(json);
    if (status >= 400 && status < 500 && json is Map<String, Object?>) {
      final problem = readJson(() => ProblemDto.fromJson(json));
      if (problem.code case ErrorCodes.sessionExpired || ErrorCodes.signInRequired) {
        _expirations.add(null);
        throw const RepositoryException('Prijava je istekla', failure: RepositoryFailure.sessionExpired);
      }
      return switch (problem.toDomainError()) {
        final error? => ApiRejected(error),
      // Kod koji ova verzija ne poznaje. Aplikacija ne pada, nego kaze opstu
      // recenicu: to je ono sto cuva staru verziju posle izmene pravila.
        null => ApiRefused(problem),
      };
    }
    throw RepositoryException('Server je odgovorio $status', failure: RepositoryFailure.serverError);
  }

  void close() {
    _http.close();
    _expirations.close();
  }
}

T readJson<T>(T Function() read) {
  try {
    return read();
  } on FormatException catch (cause) {
    throw RepositoryException('Odgovor nije citljiv', failure: RepositoryFailure.serverError, cause: cause);
  } on ArgumentError catch (cause) {
    throw RepositoryException('Odgovor nije citljiv', failure: RepositoryFailure.serverError, cause: cause);
  }
}

/// Za pozive koji ne smeju da budu odbijeni pravilom (citanje): odbijanje je ovde
/// kvar, a ne ishod.
T accepted<T>(ApiAnswer answer, T Function(Object? json) read) => switch (answer) {
  ApiAccepted(:final json) => readJson(() => read(json)),
  ApiRejected(:final error) => throw RepositoryException(
    'Neocekivano odbijanje: $error',
    failure: RepositoryFailure.serverError,
  ),
  ApiRefused(:final problem) => throw RepositoryException(
    'Server nije prihvatio zahtev: ${problem.code}',
    failure: RepositoryFailure.refused,
  ),
};

/// Za pozive koji smeju da budu odbijeni pravilom (izmena): odbijanje je `Failure`,
/// isti oblik koji bi vratio i domen da je pravilo proverio sam klijent.
Result<T> resultOf<T>(ApiAnswer answer, T Function(Object? json) read) => switch (answer) {
  ApiAccepted(:final json) => Success(readJson(() => read(json))),
  ApiRejected(:final error) => Failure(error),
  ApiRefused(:final problem) => throw RepositoryException(
    'Server nije prihvatio zahtev: ${problem.code}',
    failure: RepositoryFailure.refused,
  ),
};

Map<String, Object?> object(Object? json) => switch (json) {
  final Map<String, Object?> object => object,
  _ => throw FormatException('Ocekivan je JSON objekat', json),
};

List<Map<String, Object?>> objects(Object? json) => switch (json) {
  final List<Object?> list => [for (final item in list) object(item)],
  _ => throw FormatException('Ocekivana je JSON lista', json),
};
