import '../entities/accessibility_profile.dart';
import '../entities/user_profile.dart';

abstract class UserRepository {
  Future<AccessibilityProfile> getAccessibilityProfile();

  Future<AccessibilityProfile> updateAccessibilityProfile({
    List<String> disabilityTypes = const [],
    List<String> assistanceNeeds = const [],
    required String visibility,
    required bool consentGranted,
  });

  Future<Map<String, dynamic>> exportUserData();

  Future<void> anonymizeAccount();

  Future<UserProfile> getUserPublicProfile(String userId);
}
