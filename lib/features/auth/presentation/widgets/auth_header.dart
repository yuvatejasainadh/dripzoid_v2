import 'package:flutter/material.dart';

import 'package:dripzoid_v2/shared/widgets/app_logo.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Hero(
      tag: "logo",
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            const AppLogo(
              size: 110,
            ),

            const SizedBox(height: 28),

            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 10),

            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 320,
              ),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}