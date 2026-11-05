import '../../core/storage/secure_token_storage.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient dioClient;
  final SecureTokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.dioClient,
    SecureTokenStorage? tokenStorage,
  }) : tokenStorage = tokenStorage ?? SecureTokenStorage();

  @override
  Future<UserProfile> register({
    required String name,
    required String email,
    required String handle,
    required String password,
    String acceptTermsVersion = '1.0.0',
  }) async {
    final response = await dioClient.dio.post(
      '/api/v1/auth/register',
      data: {
        'name': name,
        'email': email,
        'handle': handle,
        'password': password,
        'acceptTermsVersion': acceptTermsVersion,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    await tokenStorage.saveToken(token);

    return UserProfile(
      id: userJson['id'] as String,
      name: userJson['name'] as String,
      email: userJson['email'] as String,
      handle: userJson['handle'] as String,
      role: userJson['role'] as String? ?? 'USER',
      avatarUrl: userJson['avatarUrl'] as String?,
    );
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final response = await dioClient.dio.post(
      '/api/v1/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    await tokenStorage.saveToken(token);

    return UserProfile(
      id: userJson['id'] as String,
      name: userJson['name'] as String,
      email: userJson['email'] as String,
      handle: userJson['handle'] as String,
      role: userJson['role'] as String? ?? 'USER',
      avatarUrl: userJson['avatarUrl'] as String?,
    );
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clearToken();
  }

  @override
  Future<String?> getStoredToken() async {
    return tokenStorage.getToken();
  }
}
