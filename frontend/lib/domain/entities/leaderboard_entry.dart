import 'package:frontend/core/base/equatable.dart';

class LeaderboardEntry extends Equatable {
  final int rank;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int points;
  final String levelName;
  final String? levelId;
  final String? badgeIcon;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.points,
    required this.levelName,
    this.levelId,
    this.badgeIcon,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      points: json['points'] as int,
      levelName: json['level_name'] as String,
      levelId: json['level_id'] as String?,
      badgeIcon: json['badge_icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': userId,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'points': points,
      'level_name': levelName,
      'level_id': levelId,
      'badge_icon': badgeIcon,
    };
  }

  @override
  List<Object?> get props => [
        rank,
        userId,
        displayName,
        avatarUrl,
        points,
        levelName,
        levelId,
        badgeIcon,
      ];
}
