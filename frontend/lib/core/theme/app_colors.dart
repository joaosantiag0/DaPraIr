import 'package:flutter/material.dart';

class AppColors {
  // Primary Accessibility Colors (High Contrast, WCAG AAA compliant)
  static const Color primaryBlue = Color(0xFF0D47A1);      // Deep rich accessible blue (Contrast > 7:1 on white)
  static const Color primaryDark = Color(0xFF002171);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryContainer = Color(0xFFEFF6FF); // Soft blue surface container

  // Secondary Accents
  static const Color accentTeal = Color(0xFF004D40);       // Contrast > 7:1 on white
  static const Color accentTealLight = Color(0xFF00796B);
  static const Color secondaryContainer = Color(0xFFE0F2F1);

  // Status & Alerts (WCAG Compliant)
  static const Color warningOrange = Color(0xFFB71C1C);    // Outdated review / Alert badge
  static const Color warningLight = Color(0xFFFEE2E2);
  static const Color underReviewYellow = Color(0xFFB45309); // 1-2 reports (high contrast amber)
  static const Color underReviewLight = Color(0xFFFEF3C7);
  static const Color successGreen = Color(0xFF15803D);     // Accessible green
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color starGold = Color(0xFFD97706);

  // Neutral Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC);  // Soft slate tinted background
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);      // Clean subtle card/divider border
  static const Color borderMedium = Color(0xFF94A3B8);     // Field border for high definition

  // Neutral Texts (WCAG AA/AAA on light surface)
  static const Color textPrimary = Color(0xFF0F172A);     // Slate 900 > 15:1
  static const Color textSecondary = Color(0xFF334155);   // Slate 700 > 8:1
  static const Color textHint = Color(0xFF64748B);        // Slate 500 > 4.5:1

  // High Contrast Mode (Preto & Amarelo / Branco puro)
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcSurface = Color(0xFF121212);
  static const Color hcPrimaryYellow = Color(0xFFFFD600); // Yellow on black > 14:1
  static const Color hcText = Color(0xFFFFFFFF);          // White on black 21:1
  static const Color hcBorder = Color(0xFFFFFF00);        // Pure Yellow border
  static const Color hcError = Color(0xFFFF5252);
}
