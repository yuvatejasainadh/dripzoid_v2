import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/product_attribution.dart';

/// Redesigned modern, premium, and minimal About Dripzoid screen.
///
/// Embodies the Dripzoid black-and-white street-luxury visual identity,
/// showcasing the brand name, tagline "Wear The Confidence", verified brand pillars,
/// SAI Labs product attribution, and dynamic platform version info.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Dripzoid'),
        centerTitle: true,
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;

          return ResponsiveContainer(
            maxWidth: 640,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),

                  // 1. BRAND HERO
                  const AppLogo(size: 80),
                  const SizedBox(height: 20),
                  Text(
                    'DRIPZOID',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Wear The Confidence',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Text(
                      'Minimal, premium clothing designed to help you express your individuality with confidence. Thoughtfully designed for everyday style, with premium fabrics and a focus on fit and feel.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Action Buttons
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                        label: const Text('Shop Now'),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/shop'),
                        icon: const Icon(Icons.explore_outlined, size: 18),
                        label: const Text('Explore Collections'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurface,
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // 2. BRAND PILLARS
                  _buildBrandPillars(theme),
                  const SizedBox(height: 36),

                  // 3. SAI LABS ATTRIBUTION
                  const ProductAttribution(),
                  const SizedBox(height: 24),

                  // 4. COPYRIGHT & VERSION FOOTER
                  Text(
                    'Version ${info?.version ?? '2.0.0'} (${info?.buildNumber ?? '1'})',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 Dripzoid. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandPillars(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;
        final items = [
          _buildPillarCard(
            theme,
            icon: Icons.flag_outlined,
            title: 'FOUNDED',
            value: '2025',
            description: 'Established in India',
          ),
          _buildPillarCard(
            theme,
            icon: Icons.local_shipping_outlined,
            title: 'SHIPPING',
            value: 'Across India',
            description: 'Fast delivery nationwide',
          ),
          _buildPillarCard(
            theme,
            icon: Icons.check_circle_outline,
            title: 'QUALITY',
            value: 'Premium Fabrics',
            description: 'Focus on fit and feel',
          ),
        ];

        if (isNarrow) {
          return Column(
            children: [
              items[0],
              const SizedBox(height: 12),
              items[1],
              const SizedBox(height: 12),
              items[2],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: items[0]),
            const SizedBox(width: 12),
            Expanded(child: items[1]),
            const SizedBox(width: 12),
            Expanded(child: items[2]),
          ],
        );
      },
    );
  }

  Widget _buildPillarCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
