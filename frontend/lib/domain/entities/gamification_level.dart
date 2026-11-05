import 'package:frontend/core/base/equatable.dart';

class GamificationLevel extends Equatable {
  final String id;
  final String name;
  final int minPoints;
  final int levelOrder;
  final String? badgeIconUrl;
  final String description;

  const GamificationLevel({
    required this.id,
    required this.name,
    required this.minPoints,
    required this.levelOrder,
    this.badgeIconUrl,
    required this.description,
  });

  factory GamificationLevel.fromJson(Map<String, dynamic> json) {
    return GamificationLevel(
      id: json['id'] as String,
      name: json['name'] as String,
      minPoints: json['min_points'] as int,
      levelOrder: json['level_order'] as int,
      badgeIconUrl: json['badge_icon_url'] as String?,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'min_points': minPoints,
      'level_order': levelOrder,
      'badge_icon_url': badgeIconUrl,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [id, name, minPoints, levelOrder, badgeIconUrl, description];
}
