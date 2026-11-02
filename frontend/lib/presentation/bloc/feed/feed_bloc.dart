import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/feed_item.dart';
import '../../../domain/entities/content_report.dart';
import '../../../domain/repositories/feed_repository.dart';
import '../../../domain/repositories/reports_repository.dart';

// EVENTS
abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedRequested extends FeedEvent {
  final double? latitude;
  final double? longitude;

  const LoadFeedRequested({this.latitude, this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class RefreshFeedRequested extends FeedEvent {
  final double? latitude;
  final double? longitude;

  const RefreshFeedRequested({this.latitude, this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class SubmitReportRequested extends FeedEvent {
  final String targetType;
  final String targetId;
  final ReportReason reason;
  final String? details;

  const SubmitReportRequested({
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.details,
  });

  @override
  List<Object?> get props => [targetType, targetId, reason, details];
}

// STATES
enum FeedStatus { initial, loading, loaded, refreshing, error }

class FeedState extends Equatable {
  final FeedStatus status;
  final FeedData? feedData;
  final bool isSubmittingReport;
  final ContentReportResult? lastReportResult;
  final String? errorMessage;
  final String? reportMessage;

  const FeedState({
    this.status = FeedStatus.initial,
    this.feedData,
    this.isSubmittingReport = false,
    this.lastReportResult,
    this.errorMessage,
    this.reportMessage,
  });

  FeedState copyWith({
    FeedStatus? status,
    FeedData? feedData,
    bool? isSubmittingReport,
    ContentReportResult? lastReportResult,
    String? errorMessage,
    String? reportMessage,
  }) {
    return FeedState(
      status: status ?? this.status,
      feedData: feedData ?? this.feedData,
      isSubmittingReport: isSubmittingReport ?? this.isSubmittingReport,
      lastReportResult: lastReportResult ?? this.lastReportResult,
      errorMessage: errorMessage ?? this.errorMessage,
      reportMessage: reportMessage ?? this.reportMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        feedData,
        isSubmittingReport,
        lastReportResult,
        errorMessage,
        reportMessage,
      ];
}

// BLOC
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository feedRepository;
  final ReportsRepository reportsRepository;

  FeedBloc({
    required this.feedRepository,
    required this.reportsRepository,
  }) : super(const FeedState()) {
    on<LoadFeedRequested>(_onLoadFeed);
    on<RefreshFeedRequested>(_onRefreshFeed);
    on<SubmitReportRequested>(_onSubmitReport);
  }

  Future<void> _onLoadFeed(LoadFeedRequested event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.loading));
    try {
      final feed = await feedRepository.getFeed(
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(state.copyWith(status: FeedStatus.loaded, feedData: feed));
    } catch (e) {
      emit(state.copyWith(status: FeedStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshFeed(RefreshFeedRequested event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.refreshing));
    try {
      final feed = await feedRepository.getFeed(
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(state.copyWith(status: FeedStatus.loaded, feedData: feed));
    } catch (e) {
      emit(state.copyWith(status: FeedStatus.loaded));
    }
  }

  Future<void> _onSubmitReport(SubmitReportRequested event, Emitter<FeedState> emit) async {
    emit(state.copyWith(isSubmittingReport: true));
    try {
      final result = await reportsRepository.submitReport(
        targetType: event.targetType,
        targetId: event.targetId,
        reason: event.reason,
        details: event.details,
      );

      // If report target is a review in current feed and became quarantined, remove it from feed
      FeedData? updatedData = state.feedData;
      if (updatedData != null && event.targetType == 'REVIEW') {
        if (result.targetStatus == 'QUARANTINED') {
          final filteredReviews = updatedData.recentReviews.where((r) => r.id != event.targetId).toList();
          updatedData = FeedData(
            highlightedPlaces: updatedData.highlightedPlaces,
            recentReviews: filteredReviews,
            upcomingEvents: updatedData.upcomingEvents,
            accessibilityTips: updatedData.accessibilityTips,
          );
        }
      }

      emit(state.copyWith(
        isSubmittingReport: false,
        lastReportResult: result,
        feedData: updatedData,
        reportMessage: 'Denúncia registrada. Obrigado por ajudar a manter a comunidade segura.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmittingReport: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
