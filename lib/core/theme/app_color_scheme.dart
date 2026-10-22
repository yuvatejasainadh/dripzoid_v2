import 'package:flutter/material.dart';
import 'tokens/app_colors.dart';

class AppColorScheme {
  AppColorScheme._();

  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightOnPrimary,
    secondary: AppColors.lightTextSecondary,
    onSecondary: AppColors.lightOnPrimary,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightTextPrimary,
    onSurfaceVariant: AppColors.lightTextSecondary,
    surfaceContainerHighest: AppColors.lightSurfaceVariant,
    outline: AppColors.lightTextTertiary,
    outlineVariant: AppColors.lightBorder,
    shadow: Colors.black,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    secondary: AppColors.darkTextSecondary,
    onSecondary: AppColors.darkOnPrimary,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    onSurfaceVariant: AppColors.darkTextSecondary,
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
    outline: AppColors.darkTextTertiary,
    outlineVariant: AppColors.darkBorder,
    shadow: Colors.black,
  );
}
