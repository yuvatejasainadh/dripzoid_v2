import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color borderSubtle;
  final Color dividerSubtle;
  final Color inputFill;
  final Color cardBackground;

  const AppColorsExtension({
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.borderSubtle,
    required this.dividerSubtle,
    required this.inputFill,
    required this.cardBackground,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? borderSubtle,
    Color? dividerSubtle,
    Color? inputFill,
    Color? cardBackground,
  }) {
    return AppColorsExtension(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      dividerSubtle: dividerSubtle ?? this.dividerSubtle,
      inputFill: inputFill ?? this.inputFill,
      cardBackground: cardBackground ?? this.cardBackground,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      dividerSubtle: Color.lerp(dividerSubtle, other.dividerSubtle, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
    );
  }

  static AppColorsExtension of(BuildContext context) {
    return Theme.of(context).extension<AppColorsExtension>()!;
  }
}
