import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/leaderboard_entry.dart';
import '../../../domain/repositories/gamification_repository.dart';
import 'gamification_event.dart';
import 'gamification_state.dart';

class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GamificationRepository repository;

  GamificationBloc({required this.repository})
      : super(const GamificationState()) {
    on<LoadGamificationProfile>(_onLoadProfile);
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<LoadTransactionsHistory>(_onLoadTransactions);
    on<UpdatePrivacySettings>(_onUpdatePrivacy);
    on<PointsAwardedNotification>(_onPointsNotification);
  }

  Future<void> _onLoadProfile(
    LoadGamificationProfile event,
    Emitter<GamificationState> emit,
  ) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    try {
      final profile = await repository.getProfile();
      emit(state.copyWith(
        status: GamificationStatus.success,
        profile: profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GamificationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<GamificationState> emit,
  ) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    try {
      final data = await repository.getLeaderboard(
        period: event.period,
        page: event.page,
      );

      final leaderboardEntries = (data['leaderboard'] as List<dynamic>?)
              ?.cast<LeaderboardEntry>() ??
          [];

      emit(state.copyWith(
        status: GamificationStatus.success,
        leaderboard: leaderboardEntries,
        activePeriod: (data['period'] as String?) ?? event.period,
        totalParticipants: (data['total_participants'] as int?) ?? 0,
        userRank: data['user_rank'] as Map<String, dynamic>?,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GamificationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsHistory event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      final txs = await repository.getTransactions(page: event.page);
      emit(state.copyWith(transactions: txs));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdatePrivacy(
    UpdatePrivacySettings event,
    Emitter<GamificationState> emit,
  ) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    try {
      final updated = await repository.updatePreferences(
        isRankingVisible: event.isRankingVisible,
        useAnonymousNickname: event.useAnonymousNickname,
        customNickname: event.customNickname,
      );
      emit(state.copyWith(
        status: GamificationStatus.success,
        profile: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GamificationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onPointsNotification(
    PointsAwardedNotification event,
    Emitter<GamificationState> emit,
  ) {
    emit(state.copyWith(
      recentAwardedPoints: event.points,
      pointsBannerMessage: event.message,
    ));
  }
}
