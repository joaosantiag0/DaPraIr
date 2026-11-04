import 'package:frontend/core/base/equatable.dart';

class AccessibilityProfile extends Equatable {
  final String userId;
  final List<String> disabilityTypes;
  final List<String> assistanceNeeds;
  final String visibility; // PUBLIC, FRIENDS_ONLY, PRIVATE

  const AccessibilityProfile({
    required this.userId,
    this.disabilityTypes = const [],
    this.assistanceNeeds = const [],
    this.visibility = 'PRIVATE',
  });

  bool get isPrivate => visibility == 'PRIVATE';
  bool get isFriendsOnly => visibility == 'FRIENDS_ONLY';
  bool get isPublic => visibility == 'PUBLIC';

  @override
  List<Object?> get props => [userId, disabilityTypes, assistanceNeeds, visibility];
}
