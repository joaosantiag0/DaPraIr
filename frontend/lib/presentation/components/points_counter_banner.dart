import 'package:flutter/material.dart';

class PointsCounterBanner extends StatelessWidget {
  final int points;
  final String message;
  final VoidCallback? onDismiss;

  const PointsCounterBanner({
    super.key,
    required this.points,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Parabéns! Você ganhou $points pontos. $message',
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.amber.shade900,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.stars, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+$points PONTOS GANHOS!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Fechar notificação',
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}
