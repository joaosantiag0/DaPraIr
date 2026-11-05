import '../../core/network/dio_client.dart';
import '../../domain/entities/accessibility_profile.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final DioClient dioClient;

  UserRepositoryImpl({required this.dioClient});

  @override
  Future<AccessibilityProfile> getAccessibilityProfile() async {
    final response = await dioClient.dio.get('/api/v1/users/me/accessibility-profile');
    final json = response.data as Map<String, dynamic>;
    return AccessibilityProfile(
      userId: json['userId'] as String? ?? '',
      disabilityTypes: (json['disabilityTypes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      assistanceNeeds: (json['assistanceNeeds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      visibility: json['visibility'] as String? ?? 'PRIVATE',
    );
  }

  @override
  Future<AccessibilityProfile> updateAccessibilityProfile({
    List<String> disabilityTypes = const [],
    List<String> assistanceNeeds = const [],
    required String visibility,
    required bool consentGranted,
  }) async {
    final response = await dioClient.dio.put(
      '/api/v1/users/me/accessibility-profile',
      data: {
        'disabilityTypes': disabilityTypes,
        'assistanceNeeds': assistanceNeeds,
        'visibility': visibility,
        'consentGranted': consentGranted,
      },
    );
    final json = response.data as Map<String, dynamic>;
    return AccessibilityProfile(
      userId: json['userId'] as String? ?? '',
      disabilityTypes: (json['disabilityTypes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      assistanceNeeds: (json['assistanceNeeds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      visibility: json['visibility'] as String? ?? 'PRIVATE',
    );
  }

  @override
  Future<Map<String, dynamic>> exportUserData() async {
    final response = await dioClient.dio.get('/api/v1/users/me/export-data');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> anonymizeAccount() async {
    await dioClient.dio.post('/api/v1/users/me/anonymize', data: {});
  }

  @override
  Future<UserProfile> getUserPublicProfile(String userId) async {
    final response = await dioClient.dio.get('/api/v1/users/$userId');
    final json = response.data as Map<String, dynamic>;
    final accJson = json['accessibilityProfile'] as Map<String, dynamic>?;

    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: '',
      handle: json['handle'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      badges: (json['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      accessibilityProfile: accJson != null
          ? AccessibilityProfile(
              userId: json['id'] as String,
              disabilityTypes: (accJson['disabilityTypes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
              assistanceNeeds: (accJson['assistanceNeeds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
              visibility: accJson['visibility'] as String? ?? 'PRIVATE',
            )
          : null,
    );
  }
}
