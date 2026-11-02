import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/domain/entities/feed_item.dart';
import 'package:frontend/domain/entities/content_report.dart';
import 'package:frontend/domain/repositories/feed_repository.dart';
import 'package:frontend/domain/repositories/reports_repository.dart';
import 'package:frontend/presentation/bloc/feed/feed_bloc.dart';

class MockFeedRepository extends Mock implements FeedRepository {}
class MockReportsRepository extends Mock implements ReportsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(ReportReason.inaccurateData);
  });

  late MockFeedRepository mockFeedRepo;
  late MockReportsRepository mockReportsRepo;
  late FeedBloc feedBloc;

  final sampleFeed = const FeedData(
    highlightedPlaces: [],
    recentReviews: [],
    upcomingEvents: [],
    accessibilityTips: [],
  );

  setUp(() {
    mockFeedRepo = MockFeedRepository();
    mockReportsRepo = MockReportsRepository();
    feedBloc = FeedBloc(
      feedRepository: mockFeedRepo,
      reportsRepository: mockReportsRepo,
    );
  });

  tearDown(() {
    feedBloc.close();
  });

  test('LoadFeedRequested emits [loading, loaded] on success', () async {
    when(() => mockFeedRepo.getFeed(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async => sampleFeed);

    expectLater(
      feedBloc.stream,
      emitsInOrder([
        const FeedState(status: FeedStatus.loading),
        FeedState(status: FeedStatus.loaded, feedData: sampleFeed),
      ]),
    );

    feedBloc.add(const LoadFeedRequested());
  });

  test('SubmitReportRequested submits report and emits success message', () async {
    const reportResult = ContentReportResult(
      reportId: 'rep-1',
      targetType: 'REVIEW',
      targetId: 'rev-1',
      distinctReportsCount: 1,
      targetStatus: 'UNDER_REVIEW',
    );

    when(() => mockReportsRepo.submitReport(
          targetType: any(named: 'targetType'),
          targetId: any(named: 'targetId'),
          reason: any(named: 'reason'),
          details: any(named: 'details'),
        )).thenAnswer((_) async => reportResult);

    expectLater(
      feedBloc.stream,
      emitsInOrder([
        const FeedState(isSubmittingReport: true),
        predicate<FeedState>((state) =>
            !state.isSubmittingReport &&
            state.lastReportResult == reportResult &&
            state.reportMessage != null),
      ]),
    );

    feedBloc.add(const SubmitReportRequested(
      targetType: 'REVIEW',
      targetId: 'rev-1',
      reason: ReportReason.inaccurateData,
    ));
  });
}
