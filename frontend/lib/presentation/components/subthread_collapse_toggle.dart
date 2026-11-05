import 'package:flutter/material.dart';

class SubthreadCollapseToggle extends StatelessWidget {
  final bool isCollapsed;
  final int repliesCount;
  final VoidCallback onTap;

  const SubthreadCollapseToggle({
    super.key,
    required this.isCollapsed,
    required this.repliesCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = isCollapsed
        ? 'Expandir $repliesCount ${repliesCount == 1 ? "resposta" : "respostas"} nesta subthread'
        : 'Recolher $repliesCount ${repliesCount == 1 ? "resposta" : "respostas"} nesta subthread';

    return Semantics(
      button: true,
      onTap: onTap,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                size: 20,
                color: const Color(0xFF0D47A1),
              ),
              const SizedBox(width: 4),
              Text(
                isCollapsed ? 'Ver $repliesCount respostas' : 'Recolher respostas',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
