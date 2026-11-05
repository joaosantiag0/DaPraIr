import 'package:flutter/material.dart';
import '../../domain/entities/forum_category.dart';

class ForumCategoryCard extends StatelessWidget {
  final ForumCategory category;
  final VoidCallback onTap;

  const ForumCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  IconData _resolveIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'directions_bus':
      case 'bus':
        return Icons.directions_bus;
      case 'restaurant':
        return Icons.restaurant;
      case 'theater_comedy':
      case 'theater':
        return Icons.theater_comedy;
      case 'devices':
        return Icons.devices;
      case 'gavel':
        return Icons.gavel;
      default:
        return Icons.forum_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      label: 'Categoria ${category.name}, ${category.topicsCount} tópicos. Toque para ver discussões.',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Icon(
                    _resolveIcon(category.iconName),
                    color: const Color(0xFF0D47A1),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${category.topicsCount} tópicos',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
