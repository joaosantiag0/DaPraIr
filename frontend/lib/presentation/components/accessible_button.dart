import 'package:flutter/material.dart';

class AccessibleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final String? semanticHint;
  final double minHeight;

  const AccessibleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.semanticHint,
    this.minHeight = 48.0, // Minimum WCAG 2.1 touch target
  });

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = onPressed != null && !isLoading;

    final childWidget = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: effectiveEnabled,
      label: label,
      hint: semanticHint,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minHeight,
          minWidth: 48.0,
        ),
        child: isSecondary
            ? OutlinedButton(
                onPressed: effectiveEnabled ? onPressed : null,
                child: childWidget,
              )
            : ElevatedButton(
                onPressed: effectiveEnabled ? onPressed : null,
                child: childWidget,
              ),
      ),
    );
  }
}
