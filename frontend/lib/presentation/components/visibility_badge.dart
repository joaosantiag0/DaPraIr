import 'package:flutter/material.dart';

class VisibilityBadge extends StatelessWidget {
  final String visibility; // PUBLIC, COMMUNITY, AUTHOR
  final bool isCompact;

  const VisibilityBadge({
    super.key,
    required this.visibility,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (label, semanticDescription, icon, bgColor, fgColor, borderColor) = _getConfig();

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: semanticDescription,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 6 : 8,
          vertical: isCompact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isCompact ? 12 : 14, color: fgColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: fgColor,
                fontSize: isCompact ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, String, IconData, Color, Color, Color) _getConfig() {
    switch (visibility.toUpperCase()) {
      case 'COMMUNITY':
        return (
          'Comunidade',
          'Visibilidade: Comunidade (restrito a usuários autenticados)',
          Icons.groups_outlined,
          const Color(0xFFEEF2FF), // Indigo 50
          const Color(0xFF312E81), // Indigo 900 (Contrast > 10:1)
          const Color(0xFFC7D2FE), // Indigo 200
        );
      case 'AUTHOR':
        return (
          'Privado',
          'Visibilidade: Privado (visível apenas para você e o autor)',
          Icons.lock_outline,
          const Color(0xFFFEF3C7), // Amber 100
          const Color(0xFF78350F), // Amber 900 (Contrast > 8:1)
          const Color(0xFFFDE68A), // Amber 200
        );
      case 'PUBLIC':
      default:
        return (
          'Público',
          'Visibilidade: Pública (aberto a visitantes anônimos e indexação)',
          Icons.public_outlined,
          const Color(0xFFECFDF5), // Emerald 50
          const Color(0xFF065F46), // Emerald 800 (Contrast > 7:1)
          const Color(0xFFA7F3D0), // Emerald 200
        );
    }
  }
}
