import '../entities/gamification_profile.dart';
import '../entities/gamification_level.dart';
import '../entities/gamification_transaction.dart';

abstract class GamificationRepository {
  Future<GamificationProfile> getProfile();

  Future<Map<String, dynamic>> getLeaderboard({
    String period = 'monthly',
    int page = 1,
    int limit = 20,
  });

  Future<List<GamificationTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
  });

  Future<List<GamificationLevel>> getLevels();

  Future<GamificationProfile> updatePreferences({
    bool? isRankingVisible,
    bool? useAnonymousNickname,
    String? customNickname,
  });
}
