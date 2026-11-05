import 'package:frontend/core/base/equatable.dart';

abstract class GamificationEvent extends Equatable {
  const GamificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadGamificationProfile extends GamificationEvent {}

class LoadLeaderboard extends GamificationEvent {
  final String period;
  final int page;

  const LoadLeaderboard({this.period = 'monthly', this.page = 1});

  @override
  List<Object?> get props => [period, page];
}

class LoadTransactionsHistory extends GamificationEvent {
  final int page;

  const LoadTransactionsHistory({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class UpdatePrivacySettings extends GamificationEvent {
  final bool? isRankingVisible;
  final bool? useAnonymousNickname;
  final String? customNickname;

  const UpdatePrivacySettings({
    this.isRankingVisible,
    this.useAnonymousNickname,
    this.customNickname,
  });

  @override
  List<Object?> get props => [isRankingVisible, useAnonymousNickname, customNickname];
}

class PointsAwardedNotification extends GamificationEvent {
  final int points;
  final String message;

  const PointsAwardedNotification({required this.points, required this.message});

  @override
  List<Object?> get props => [points, message];
}
