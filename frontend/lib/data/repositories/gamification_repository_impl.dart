import 'package:dio/dio.dart';
import '../../domain/entities/gamification_level.dart';
import '../../domain/entities/gamification_profile.dart';
import '../../domain/entities/gamification_transaction.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/gamification_repository.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final Dio dio;

  GamificationRepositoryImpl({required this.dio});

  @override
  Future<GamificationProfile> getProfile() async {
    final response = await dio.get('/api/v1/gamification/profile');
    return GamificationProfile.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getLeaderboard({
    String period = 'monthly',
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      '/api/v1/gamification/leaderboard',
      queryParameters: {
        'period': period,
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final entriesRaw = data['leaderboard'] as List<dynamic>? ?? [];
    final entries = entriesRaw
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return {
      'period': data['period'],
      'total_participants': data['total_participants'],
      'user_rank': data['user_rank'],
      'leaderboard': entries,
    };
  }

  @override
  Future<List<GamificationTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      '/api/v1/gamification/transactions',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['transactions'] as List<dynamic>? ?? [];
    return list
        .map((t) => GamificationTransaction.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<GamificationLevel>> getLevels() async {
    final response = await dio.get('/api/v1/gamification/levels');
    final list = response.data as List<dynamic>? ?? [];
    return list
        .map((l) => GamificationLevel.fromJson(l as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GamificationProfile> updatePreferences({
    bool? isRankingVisible,
    bool? useAnonymousNickname,
    String? customNickname,
  }) async {
    final response = await dio.put(
      '/api/v1/gamification/preferences',
      data: {
        if (isRankingVisible != null) 'is_ranking_visible': isRankingVisible,
        if (useAnonymousNickname != null)
          'use_anonymous_nickname': useAnonymousNickname,
        if (customNickname != null) 'custom_nickname': customNickname,
      },
    );
    return GamificationProfile.fromJson(response.data as Map<String, dynamic>);
  }
}
