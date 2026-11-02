import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile> register({
    required String name,
    required String email,
    required String handle,
    required String password,
    String acceptTermsVersion = '1.0.0',
  });

  Future<UserProfile> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<String?> getStoredToken();
}
