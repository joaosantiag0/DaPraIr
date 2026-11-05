import '../../core/network/dio_client.dart';
import '../../domain/entities/social_connection.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/social_repository.dart';

class SocialRepositoryImpl implements SocialRepository {
  final DioClient dioClient;

  SocialRepositoryImpl({required this.dioClient});

  @override
  Future<List<SocialConnection>> getConnections() async {
    final response = await dioClient.dio.get('/api/v1/social/connections');
    final list = (response.data as List<dynamic>?) ?? [];

    return list.map((json) {
      final map = json as Map<String, dynamic>? ?? {};
      final p = (map['peer'] as Map<String, dynamic>?) ?? {};
      final rawDate = map['createdAt'] ?? map['created_at'];
      final createdAt = rawDate != null
          ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
          : DateTime.now();

      return SocialConnection(
        id: (map['id'] ?? '').toString(),
        status: (map['status'] ?? 'PENDING').toString(),
        isOutgoing: map['isOutgoing'] as bool? ?? false,
        createdAt: createdAt,
        peer: SocialPeer(
          id: (p['id'] ?? '').toString(),
          name: (p['name'] ?? 'Usuário').toString(),
          handle: (p['handle'] ?? '').toString(),
          avatarUrl: p['avatarUrl'] as String?,
          bio: p['bio'] as String?,
        ),
      );
    }).toList();
  }

  @override
  Future<SocialConnection> sendConnectionRequest(String targetUserId) async {
    final response = await dioClient.dio.post(
      '/api/v1/social/connections',
      data: {'targetUserId': targetUserId},
    );
    final map = response.data as Map<String, dynamic>? ?? {};
    final rawDate = map['created_at'] ?? map['createdAt'];
    final createdAt = rawDate != null
        ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
        : DateTime.now();

    return SocialConnection(
      id: (map['id'] ?? '').toString(),
      status: (map['status'] ?? 'PENDING').toString(),
      isOutgoing: true,
      createdAt: createdAt,
      peer: SocialPeer(id: targetUserId, name: '', handle: ''),
    );
  }

  @override
  Future<SocialConnection> updateConnectionStatus(String connectionId, String status) async {
    final response = await dioClient.dio.patch(
      '/api/v1/social/connections/$connectionId',
      data: {'status': status},
    );
    final map = response.data as Map<String, dynamic>? ?? {};
    final rawDate = map['created_at'] ?? map['createdAt'];
    final createdAt = rawDate != null
        ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
        : DateTime.now();

    return SocialConnection(
      id: (map['id'] ?? connectionId).toString(),
      status: (map['status'] ?? status).toString(),
      isOutgoing: false,
      createdAt: createdAt,
      peer: const SocialPeer(id: '', name: '', handle: ''),
    );
  }

  @override
  Future<List<UserProfile>> getRecommendations() async {
    final response = await dioClient.dio.get('/api/v1/social/recommendations');
    final list = (response.data as List<dynamic>?) ?? [];

    return list.map((json) {
      final map = json as Map<String, dynamic>? ?? {};
      return UserProfile(
        id: (map['id'] ?? '').toString(),
        name: (map['name'] ?? 'Usuário').toString(),
        email: (map['email'] ?? '').toString(),
        handle: (map['handle'] ?? '').toString(),
        avatarUrl: map['avatarUrl'] as String?,
        bio: map['bio'] as String?,
        badges: (map['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
    }).toList();
  }

  @override
  Future<List<SocialConnection>> getBlockedUsers() async {
    final response = await dioClient.dio.get('/api/v1/social/blocked');
    final list = (response.data as List<dynamic>?) ?? [];

    return list.map((json) {
      final map = json as Map<String, dynamic>? ?? {};
      final p = (map['peer'] as Map<String, dynamic>?) ?? {};
      final rawDate = map['createdAt'] ?? map['created_at'];
      final createdAt = rawDate != null
          ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
          : DateTime.now();

      return SocialConnection(
        id: (map['id'] ?? '').toString(),
        status: (map['status'] ?? 'BLOCKED').toString(),
        isOutgoing: map['isOutgoing'] as bool? ?? false,
        createdAt: createdAt,
        peer: SocialPeer(
          id: (p['id'] ?? '').toString(),
          name: (p['name'] ?? 'Usuário').toString(),
          handle: (p['handle'] ?? '').toString(),
          avatarUrl: p['avatarUrl'] as String?,
          bio: p['bio'] as String?,
        ),
      );
    }).toList();
  }

  @override
  Future<void> blockUser(String targetUserId) async {
    await dioClient.dio.post(
      '/api/v1/social/block',
      data: {'targetUserId': targetUserId},
    );
  }

  @override
  Future<void> unblockUser(String connectionId) async {
    await dioClient.dio.delete('/api/v1/social/blocked/$connectionId');
  }
}
