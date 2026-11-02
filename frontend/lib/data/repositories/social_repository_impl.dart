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
      final p = json['peer'] as Map<String, dynamic>;
      return SocialConnection(
        id: json['id'] as String,
        status: json['status'] as String,
        isOutgoing: json['isOutgoing'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        peer: SocialPeer(
          id: p['id'] as String,
          name: p['name'] as String,
          handle: p['handle'] as String,
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
    final json = response.data as Map<String, dynamic>;
    return SocialConnection(
      id: json['id'] as String,
      status: json['status'] as String,
      isOutgoing: true,
      createdAt: DateTime.parse(json['created_at'] as String),
      peer: SocialPeer(id: targetUserId, name: '', handle: ''),
    );
  }

  @override
  Future<SocialConnection> updateConnectionStatus(String connectionId, String status) async {
    final response = await dioClient.dio.patch(
      '/api/v1/social/connections/$connectionId',
      data: {'status': status},
    );
    final json = response.data as Map<String, dynamic>;
    return SocialConnection(
      id: json['id'] as String,
      status: json['status'] as String,
      isOutgoing: false,
      createdAt: DateTime.parse(json['created_at'] as String),
      peer: const SocialPeer(id: '', name: '', handle: ''),
    );
  }

  @override
  Future<List<UserProfile>> getRecommendations() async {
    final response = await dioClient.dio.get('/api/v1/social/recommendations');
    final list = (response.data as List<dynamic>?) ?? [];

    return list.map((json) => UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: '',
      handle: json['handle'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      badges: (json['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    )).toList();
  }
}
