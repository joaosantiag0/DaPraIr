import '../entities/social_connection.dart';
import '../entities/user_profile.dart';

abstract class SocialRepository {
  Future<List<SocialConnection>> getConnections();

  Future<SocialConnection> sendConnectionRequest(String targetUserId);

  Future<SocialConnection> updateConnectionStatus(String connectionId, String status);

  Future<List<UserProfile>> getRecommendations();
  Future<List<SocialConnection>> getBlockedUsers();
  Future<void> blockUser(String targetUserId);
  Future<void> unblockUser(String connectionId);
}
