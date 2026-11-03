import 'package:flutter/material.dart';

class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.borderRadius,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);

    final cardWidget = Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveRadius,
        side: borderSide ?? BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: effectiveRadius,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        container: true,
        button: onTap != null,
        label: semanticLabel,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
