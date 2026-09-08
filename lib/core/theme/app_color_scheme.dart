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
    surfaceContainerHighest: AppColors.lightSurfaceVariant,
    outline: AppColors.lightBorder,
    outlineVariant: AppColors.lightDivider,
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
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
    outline: AppColors.darkBorder,
    outlineVariant: AppColors.darkDivider,
    shadow: Colors.black,
  );
}
