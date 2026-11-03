
import 'package:domain/domain.dart';

enum StatusFilter {
  waiting('Čeka odluku'),
  proposed('Skuplja potvrde'),
  published('Objavljeno'),
  closed('Odbijeno i povučeno'),
  all('Sve');

  const StatusFilter(this.label);

  final String label;

  bool matches(AscentStatus status) => switch (this) {
    StatusFilter.waiting => status is Confirmed,
    StatusFilter.proposed => status is Proposed,
    StatusFilter.published => status is Published,
    StatusFilter.closed => status is Rejected || status is Archived,
    StatusFilter.all => true,
  };
}
