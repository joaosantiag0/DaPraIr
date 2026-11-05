import 'package:frontend/core/base/equatable.dart';
import 'gamification_level.dart';

class GamificationProfile extends Equatable {
  final int pointsTotal;
  final int pointsCurrent;
  final GamificationLevel currentLevel;
  final GamificationLevel? nextLevel;
  final int pointsToNextLevel;
  final bool isRankingVisible;
  final bool useAnonymousNickname;
  final String? customNickname;

  const GamificationProfile({
    required this.pointsTotal,
    required this.pointsCurrent,
    required this.currentLevel,
    this.nextLevel,
    required this.pointsToNextLevel,
    required this.isRankingVisible,
    required this.useAnonymousNickname,
    this.customNickname,
  });

  factory GamificationProfile.fromJson(Map<String, dynamic> json) {
    return GamificationProfile(
      pointsTotal: json['points_total'] as int? ?? 0,
      pointsCurrent: json['points_current'] as int? ?? 0,
      currentLevel: GamificationLevel.fromJson(json['current_level'] as Map<String, dynamic>),
      nextLevel: json['next_level'] != null
          ? GamificationLevel.fromJson(json['next_level'] as Map<String, dynamic>)
          : null,
      pointsToNextLevel: json['points_to_next_level'] as int? ?? 0,
      isRankingVisible: json['is_ranking_visible'] as bool? ?? true,
      useAnonymousNickname: json['use_anonymous_nickname'] as bool? ?? false,
      customNickname: json['custom_nickname'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points_total': pointsTotal,
      'points_current': pointsCurrent,
      'current_level': currentLevel.toJson(),
      'next_level': nextLevel?.toJson(),
      'points_to_next_level': pointsToNextLevel,
      'is_ranking_visible': isRankingVisible,
      'use_anonymous_nickname': useAnonymousNickname,
      'custom_nickname': customNickname,
    };
  }

  @override
  List<Object?> get props => [
        pointsTotal,
        pointsCurrent,
        currentLevel,
        nextLevel,
        pointsToNextLevel,
        isRankingVisible,
        useAnonymousNickname,
        customNickname,
      ];
}
