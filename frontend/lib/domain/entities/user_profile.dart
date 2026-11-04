import 'package:frontend/core/base/equatable.dart';
import 'accessibility_profile.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String handle;
  final String? avatarUrl;
  final String? bio;
  final String role;
  final List<String> badges;
  final bool isAnonymous;
  final AccessibilityProfile? accessibilityProfile;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.handle,
    this.avatarUrl,
    this.bio,
    this.role = 'USER',
    this.badges = const [],
    this.isAnonymous = false,
    this.accessibilityProfile,
  });

  @override
  List<Object?> get props => [id, name, email, handle, role, isAnonymous, accessibilityProfile];
}
