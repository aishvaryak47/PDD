import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryIndigo = Color(0xFF3F51B5);
  static const Color primaryPurple = Color(0xFF7C4DFF);
  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color accentBlue = Color(0xFF00B0FF);
  static const Color accentCoral = Color(0xFFFF6B6B);

  // Backgrounds
  static const Color lightBg = Color(0xFFF8F9FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);

  // Card & Glassmorphism Colors
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassDark = Color(0xCC1E293B);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFE2E8F0);
  static const Color cardBorderDark = Color(0xFF334155);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Status & Mood Colors
  static const Color moodEcstatic = Color(0xFF10B981); // Green
  static const Color moodHappy = Color(0xFF3B82F6);    // Blue
  static const Color moodNeutral = Color(0xFFF59E0B);  // Amber
  static const Color moodSad = Color(0xFF8B5CF6);      // Purple
  static const Color moodAnxious = Color(0xFFEF4444);  // Red

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryIndigo, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
