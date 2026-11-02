import 'package:flutter/material.dart';

class AppColors {
  // Primary Accessibility Colors (High Contrast, WCAG AAA compliant)
  static const Color primaryBlue = Color(0xFF0D47A1);      // Contrast > 7:1 on white
  static const Color primaryDark = Color(0xFF002171);
  static const Color primaryLight = Color(0xFF5472D3);

  // Secondary Accents
  static const Color accentTeal = Color(0xFF004D40);       // Contrast > 7:1 on white
  static const Color warningOrange = Color(0xFFB71C1C);    // Outdated review / Alert badge
  static const Color underReviewYellow = Color(0xFFE65100); // 1-2 reports
  static const Color successGreen = Color(0xFF1B5E20);

  // Neutral Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFF424242);     // Minimum 3:1 for UI borders

  // Neutral Texts (WCAG AA/AAA on light surface)
  static const Color textPrimary = Color(0xFF121212);     // Pure near-black > 15:1
  static const Color textSecondary = Color(0xFF263238);   // Dark Slate > 8:1
  static const Color textHint = Color(0xFF455A64);        // > 4.5:1

  // High Contrast Mode (Preto & Amarelo / Branco puro)
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcSurface = Color(0xFF121212);
  static const Color hcPrimaryYellow = Color(0xFFFFD600); // Yellow on black > 14:1
  static const Color hcText = Color(0xFFFFFFFF);          // White on black 21:1
  static const Color hcBorder = Color(0xFFFFFF00);        // Pure Yellow border
  static const Color hcError = Color(0xFFFF5252);
}
