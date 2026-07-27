import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme light = GoogleFonts.interTextTheme().copyWith(
    displayLarge: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),

    headlineMedium: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),

    titleLarge: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    bodyLarge: const TextStyle(
      fontSize: 16,
      color: AppColors.textPrimary,
    ),

    bodyMedium: const TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),

    labelLarge: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );

  static TextTheme dark = GoogleFonts.interTextTheme(
    ThemeData.dark().textTheme,
  );
}