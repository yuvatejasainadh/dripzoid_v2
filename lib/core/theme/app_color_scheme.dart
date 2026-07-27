import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppColorScheme {
  AppColorScheme._();

  static const light = ColorScheme(
    brightness: Brightness.light,

    primary: AppColors.primary,
    onPrimary: Colors.white,

    secondary: AppColors.secondary,
    onSecondary: Colors.white,

    error: AppColors.error,
    onError: Colors.white,

    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,

    primary: AppColors.primary,
    onPrimary: Colors.white,

    secondary: AppColors.secondary,
    onSecondary: Colors.white,

    error: AppColors.error,
    onError: Colors.white,

    surface: AppColors.darkSurface,
    onSurface: Colors.white,
  );
}