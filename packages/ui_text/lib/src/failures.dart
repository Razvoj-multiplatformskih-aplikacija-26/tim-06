import 'package:use_cases/use_cases.dart';

const serverUnreachableMessage = 'Nema veze sa serverom.';
const sessionExpiredMessage = 'Prijava je istekla. Prijavite se ponovo.';

String failureMessage(Object? cause) => switch (cause) {
  RepositoryFailure.unreachable => serverUnreachableMessage,
  RepositoryFailure.serverError => 'Greska na serveru.',
  RepositoryFailure.refused => 'Server nije prihvatio zahtev.',
  RepositoryFailure.sessionExpired => sessionExpiredMessage,
  RepositoryFailure.unavailable => 'Podaci trenutno nisu dostupni.',
  RepositoryException(:final failure) => failureMessage(failure),
  _ => 'Podaci trenutno nisu dostupni.',
};
