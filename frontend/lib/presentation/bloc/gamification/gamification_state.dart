import 'package:frontend/core/base/equatable.dart';
import '../../../domain/entities/gamification_profile.dart';
import '../../../domain/entities/gamification_transaction.dart';
import '../../../domain/entities/leaderboard_entry.dart';

enum GamificationStatus { initial, loading, success, failure }

class GamificationState extends Equatable {
  final GamificationStatus status;
  final GamificationProfile? profile;
  final List<LeaderboardEntry> leaderboard;
  final String activePeriod;
  final int totalParticipants;
  final Map<String, dynamic>? userRank;
  final List<GamificationTransaction> transactions;
  final String? errorMessage;
  final String? pointsBannerMessage;
  final int? recentAwardedPoints;

  const GamificationState({
    this.status = GamificationStatus.initial,
    this.profile,
    this.leaderboard = const [],
    this.activePeriod = 'monthly',
    this.totalParticipants = 0,
    this.userRank,
    this.transactions = const [],
    this.errorMessage,
    this.pointsBannerMessage,
    this.recentAwardedPoints,
  });

  GamificationState copyWith({
    GamificationStatus? status,
    GamificationProfile? profile,
    List<LeaderboardEntry>? leaderboard,
    String? activePeriod,
    int? totalParticipants,
    Map<String, dynamic>? userRank,
    List<GamificationTransaction>? transactions,
    String? errorMessage,
    String? pointsBannerMessage,
    int? recentAwardedPoints,
  }) {
    return GamificationState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      leaderboard: leaderboard ?? this.leaderboard,
      activePeriod: activePeriod ?? this.activePeriod,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      userRank: userRank ?? this.userRank,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage ?? this.errorMessage,
      pointsBannerMessage: pointsBannerMessage ?? this.pointsBannerMessage,
      recentAwardedPoints: recentAwardedPoints ?? this.recentAwardedPoints,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        leaderboard,
        activePeriod,
        totalParticipants,
        userRank,
        transactions,
        errorMessage,
        pointsBannerMessage,
        recentAwardedPoints,
      ];
}
