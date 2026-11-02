import 'package:flutter/material.dart';

class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Card(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
