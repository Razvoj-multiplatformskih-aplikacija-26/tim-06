import 'package:domain/domain.dart';
import 'package:fake_data/fake_data.dart';
import 'package:use_cases/use_cases.dart';


final class MobileDependencies {
  MobileDependencies({required this.clock, required this.user, required AscentRepository ascents, this.fakeRepository})
      : getAscents = GetAscents(ascents: ascents),
        createAscent = CreateAscentUseCase(ascents: ascents, clock: clock),
        submitAscent = SubmitAscent(ascents: ascents),
        confirmAscent = ConfirmAscent(ascents: ascents, clock: clock),
        publishAscent = PublishAscent(ascents: ascents, clock: clock),
        rejectAscent = RejectAscent(ascents: ascents, clock: clock),
        archiveAscent = ArchiveAscent(ascents: ascents, clock: clock);

  factory MobileDependencies.fake({Clock clock = const SystemClock(), Duration delay = const Duration(milliseconds: 600)}) {
    final repository = FakeAscentRepository(delay);
    return MobileDependencies(clock: clock, user: currentUser, ascents: repository, fakeRepository: repository);
  }

  final Clock clock;
  final User user;
  final GetAscents getAscents;
  final CreateAscentUseCase createAscent;
  final SubmitAscent submitAscent;
  final ConfirmAscent confirmAscent;
  final PublishAscent publishAscent;
  final RejectAscent rejectAscent;
  final ArchiveAscent archiveAscent;

  final FakeAscentRepository? fakeRepository;
}
