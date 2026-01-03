import 'package:flutter/material.dart';

class AppColors {
  // Background Colors
  static const Color bgDark = Color(0xFF121212);
  static const Color bgLight = Color(0xFF626262);

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);

  // Primary Buttons / Icons
  static const Color primaryBlue = Color(0xFF2563EB);

  // Rating Stars
  static const Color ratingYellow = Color(0xFFFFDF00);

  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color alertRed = Color(0xFFEF4444);

  // ✅ Background Gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.bottomLeft,
    colors: [
      bgDark,
      bgLight,
    ],
  );
}
