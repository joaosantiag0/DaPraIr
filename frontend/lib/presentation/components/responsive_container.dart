import 'package:flutter/material.dart';

/// Wraps page content with a responsive constraint to ensure optimal readability
/// and layout on wide screens (tablets, desktops, and web browsers),
/// while naturally filling 100% width on mobile screens.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 960,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  /// Preset for form screens like Login, Register, Dialogs
  const ResponsiveContainer.narrow({
    super.key,
    required this.child,
    this.padding,
    this.alignment = Alignment.topCenter,
  }) : maxWidth = 480;

  /// Preset for content cards, detail screens, review creation
  const ResponsiveContainer.medium({
    super.key,
    required this.child,
    this.padding,
    this.alignment = Alignment.topCenter,
  }) : maxWidth = 840;

  /// Preset for feeds, search, and dashboard lists
  const ResponsiveContainer.wide({
    super.key,
    required this.child,
    this.padding,
    this.alignment = Alignment.topCenter,
  }) : maxWidth = 1080;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}
