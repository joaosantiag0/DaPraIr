import 'package:frontend/core/base/equatable.dart';

class ForumCategory extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String iconName;
  final int displayOrder;
  final bool isActive;
  final int topicsCount;

  const ForumCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.iconName,
    required this.displayOrder,
    required this.isActive,
    required this.topicsCount,
  });

  factory ForumCategory.fromJson(Map<String, dynamic> json) {
    return ForumCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      iconName: json['icon_name'] as String? ?? 'forum',
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      topicsCount: (json['topics_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon_name': iconName,
      'display_order': displayOrder,
      'is_active': isActive,
      'topics_count': topicsCount,
    };
  }

  @override
  List<Object?> get props => [id, name, slug, displayOrder, isActive, topicsCount];
}
