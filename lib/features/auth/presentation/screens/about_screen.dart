import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/ui/snackbars/premium_snackbar.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/product_attribution.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _contactKey = GlobalKey();

  static const String _privacyPolicyUrl =
      'https://dripzoid-frontend.onrender.com/privacy-policy';
  static const String _phoneNumber = '+91 94940 38163';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToContact() {
    final context = _contactKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        PremiumSnackbar.showError(context, 'Could not open URL: $url');
      }
    } catch (_) {
      if (context.mounted) {
        PremiumSnackbar.showError(context, 'Could not open URL: $url');
      }
    }
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      final launched = await launchUrl(uri);
      if (!launched && context.mounted) {
        PremiumSnackbar.showError(context, 'Could not dial $phone');
      }
    } catch (_) {
      if (context.mounted) {
        PremiumSnackbar.showError(context, 'Could not dial $phone');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Dripzoid'),
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;

          return ResponsiveContainer(
            maxWidth: 760,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. HERO SECTION
                  _buildHeroSection(theme),
                  const SizedBox(height: 32),

                  // 2. BRAND HIGHLIGHTS (Founded, Pieces, Community)
                  _buildBrandHighlights(theme),
                  const SizedBox(height: 32),

                  // 3. OUR STORY
                  _buildOurStory(theme),
                  const SizedBox(height: 28),

                  // 4. MISSION & VISION
                  _buildMissionVision(theme),
                  const SizedBox(height: 28),

                  // 5. OUR VALUES
                  _buildOurValues(theme),
                  const SizedBox(height: 28),

                  // 6. QUALITY & CRAFTSMANSHIP
                  _buildQualityCraftsmanship(theme),
                  const SizedBox(height: 28),

                  // 7. SUSTAINABILITY
                  _buildSustainability(theme),
                  const SizedBox(height: 28),

                  // 8. COMMUNITY & COLLABORATIONS
                  _buildCommunityCollabs(theme),
                  const SizedBox(height: 28),

                  // 9. SIZING & FIT
                  _buildSizingFit(theme),
                  const SizedBox(height: 28),

                  // 10. SHIPPING & RETURNS
                  _buildShippingReturns(theme),
                  const SizedBox(height: 28),

                  // 11. CAREERS & WHOLESALE
                  _buildCareersWholesale(theme),
                  const SizedBox(height: 28),

                  // 12. CONTACT CTA
                  _buildContactCTA(theme),
                  const SizedBox(height: 28),

                  // 13. CONTACT DETAILS CARD (PHASE 2)
                  Container(
                    key: _contactKey,
                    child: _buildContactDetailsCard(theme),
                  ),
                  const SizedBox(height: 28),

                  // 14. HELP & FAQ + LICENSES
                  _buildHelpAndLicenses(theme),
                  const SizedBox(height: 36),

                  // 15. SAI LABS ATTRIBUTION (PHASE 4)
                  const ProductAttribution(showBrandText: true),
                  const SizedBox(height: 20),

                  // 16. COPYRIGHT & VERSION FOOTER
                  Text(
                    'Version ${info?.version ?? '2.0.0'} (${info?.buildNumber ?? '1'})',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '© 2026 Dripzoid. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. HERO SECTION
  // ---------------------------------------------------------------------------
  Widget _buildHeroSection(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 12),
          const AppLogo(size: 88),
          const SizedBox(height: 20),
          Text(
            'Dripzoid — Wear the Confidence',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Text(
              'Bold streetwear with a luxury touch. We design pieces that help you express your individuality — crafted thoughtfully, worn proudly.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 24),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/shop'),
                icon: const Icon(Icons.explore_outlined, size: 18),
                label: const Text('Explore Collections'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. BRAND HIGHLIGHTS
  // ---------------------------------------------------------------------------
  Widget _buildBrandHighlights(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 540;
        final cards = [
          _buildHighlightCard(
            theme,
            title: 'Founded',
            value: '2020',
            description: 'Built in India, shipped worldwide',
            icon: Icons.flag_outlined,
          ),
          _buildHighlightCard(
            theme,
            title: 'Pieces',
            value: 'Premium Fabrics',
            description: 'Softer feels, lasting fits',
            icon: Icons.check_circle_outline,
          ),
          _buildHighlightCard(
            theme,
            title: 'Community',
            value: 'Design Collabs',
            description: 'Creators & drop culture',
            icon: Icons.groups_outlined,
          ),
        ];

        if (isNarrow) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 12),
              cards[1],
              const SizedBox(height: 12),
              cards[2],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
            const SizedBox(width: 12),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  Widget _buildHighlightCard(
    ThemeData theme, {
    required String title,
    required String value,
    required String description,
    required IconData icon,
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

  // ---------------------------------------------------------------------------
  // 3. OUR STORY
  // ---------------------------------------------------------------------------
  Widget _buildOurStory(ThemeData theme) {
    return _buildCardSection(
      theme,
      title: 'Our Story',
      children: [
        Text(
          'Dripzoid began as a small creative collective with a simple idea: merge street authenticity with refined quality. What started as limited drops and capsule collections quickly grew into a brand recognized for clean silhouettes, bold graphics and elevated materials. Every season we iterate on fit, fabric and finish — listening to our community and staying true to our roots.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'We design for the person who wants more than a label — they want clothing that performs, endures, and amplifies how they show up in the world.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. MISSION & VISION
  // ---------------------------------------------------------------------------
  Widget _buildMissionVision(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 540;

        final missionCard = Container(
          padding: const EdgeInsets.all(18),
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
                  Icon(Icons.track_changes_outlined,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Mission',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'To craft accessible street-luxury that empowers people to wear confidence — design-forward pieces that feel premium without the pretense.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );

        final visionCard = Container(
          padding: const EdgeInsets.all(18),
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
                  Icon(Icons.visibility_outlined,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Vision',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'To be a home for modern self-expression — championing sustainable choices, meaningful collaborations, and designs that last beyond seasonal trends.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );

        if (isNarrow) {
          return Column(
            children: [
              missionCard,
              const SizedBox(height: 12),
              visionCard,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: missionCard),
            const SizedBox(width: 12),
            Expanded(child: visionCard),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 5. OUR VALUES
  // ---------------------------------------------------------------------------
  Widget _buildOurValues(ThemeData theme) {
    return _buildCardSection(
      theme,
      title: 'Our Values',
      children: [
        _buildValueRow(
          theme,
          title: 'Design-First',
          description:
              'Every collection starts with concept and fit. We obsess over silhouette and proportion.',
          icon: Icons.design_services_outlined,
        ),
        _buildValueDivider(theme),
        _buildValueRow(
          theme,
          title: 'Quality',
          description:
              'Premium fabrics, reinforced stitching and consistent sizing—garments built to last.',
          icon: Icons.diamond_outlined,
        ),
        _buildValueDivider(theme),
        _buildValueRow(
          theme,
          title: 'Community',
          description:
              'We co-create with artists, stylists and our customers—your voice shapes our drops.',
          icon: Icons.people_outline,
        ),
        _buildValueDivider(theme),
        _buildValueRow(
          theme,
          title: 'Sustainability',
          description:
              'We’re reducing waste and choosing better materials as we scale. Sustainability is a continual journey and we publish improvements as we make them.',
          icon: Icons.eco_outlined,
        ),
      ],
    );
  }

  Widget _buildValueRow(
    ThemeData theme, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: theme.colorScheme.outlineVariant, height: 1),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. QUALITY & CRAFTSMANSHIP
  // ---------------------------------------------------------------------------
  Widget _buildQualityCraftsmanship(ThemeData theme) {
    return _buildCardSection(
      theme,
      title: 'Quality & Craftsmanship',
      children: [
        Text(
          'We source materials from trusted mills and partner with experienced manufacturers to ensure consistent quality. Every stitch and finish is tested — from wash resilience to colorfastness. Our in-house fit team prototypes multiple iterations so every drop fits how it should.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        _buildBulletFeature(
            theme, 'Premium, pre-shrunk fabrics for consistent fit.'),
        const SizedBox(height: 10),
        _buildBulletFeature(theme, 'Reinforced seams at stress points.'),
        const SizedBox(height: 10),
        _buildBulletFeature(
            theme, 'Blended materials where performance matters.'),
      ],
    );
  }

  Widget _buildBulletFeature(ThemeData theme, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded,
            size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 7. SUSTAINABILITY
  // ---------------------------------------------------------------------------
  Widget _buildSustainability(ThemeData theme) {
    return _buildCardSection(
      theme,
      title: 'Sustainability',
      children: [
        Text(
          'We’re taking steps to minimize our environmental footprint — from conscious fabric choices (recycled fibers, organic cotton) to smarter packaging and limited-run drops that avoid overproduction. Sustainability is a continual journey and we publish improvements as we make them.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 480;

            final card1 = Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recycled & organic materials',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Increasing percentage each year.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );

            final card2 = Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minimal packaging',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Designs to reduce waste & bulk.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );

            if (isNarrow) {
              return Column(
                children: [
                  card1,
                  const SizedBox(height: 10),
                  card2,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: card1),
                const SizedBox(width: 10),
                Expanded(child: card2),
              ],
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 8. COMMUNITY & COLLABORATIONS
  // ---------------------------------------------------------------------------
  Widget _buildCommunityCollabs(ThemeData theme) {
    return _buildCardSection(
      theme,
      title: 'Community & Collaborations',
      children: [
        Text(
          'Our community is at the center of what we do. We collaborate with visual artists, stylists and local creatives to produce limited drops. Join our mailing list and community channels for early access, behind-the-scenes design stories and invite-only collabs.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            FilledButton.tonalIcon(
              onPressed: () {
                PremiumSnackbar.showSuccess(
                  context,
                  'Mailing List: Early access and invite-only collabs signup coming soon to the app!',
                );
              },
              icon: const Icon(Icons.mail_outline, size: 18),
              label: const Text('Join the List'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/shop'),
              icon: const Icon(Icons.style_outlined, size: 18),
              label: const Text('See Collabs'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 9. SIZING & FIT
  // ---------------------------------------------------------------------------
  Widget _buildSizingFit(ThemeData theme) {
    return _buildCardSection(
      theme,
      title: 'Sizing & Fit',
      children: [
        Text(
          'Our size guide is tailored per product. We include chest, length and sleeve measurements on every product page.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _showSizeGuideModal(context),
            icon: const Icon(Icons.straighten, size: 18),
            label: const Text('View Size Guide'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 10. SHIPPING & RETURNS
  // ---------------------------------------------------------------------------
  Widget _buildShippingReturns(ThemeData theme) {
    return _buildCardSection(
      theme,
      title: 'Shipping & Returns',
      children: [
        Text(
          'Standard shipping across India and international options available. Easy returns within 14 days of delivery.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _showShippingPolicyModal(context),
            icon: const Icon(Icons.local_shipping_outlined, size: 18),
            label: const Text('Shipping Policy'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 11. CAREERS & WHOLESALE
  // ---------------------------------------------------------------------------
  Widget _buildCareersWholesale(ThemeData theme) {
    return _buildCardSection(
      theme,
      title: 'Careers & Wholesale',
      children: [
        Text(
          'Interested in joining our growing team or stocking Dripzoid in your store?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _launchPhone(context, _phoneNumber),
            icon: const Icon(Icons.handshake_outlined, size: 18),
            label: const Text('Work With Us'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 12. CONTACT CTA
  // ---------------------------------------------------------------------------
  Widget _buildContactCTA(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.chat_bubble_outline,
                  color: theme.colorScheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Have a question or collaboration idea?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Reach out — we love hearing from customers and creators.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _scrollToContact,
            icon: const Icon(Icons.arrow_downward, size: 18),
            label: const Text('Contact Us'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 13. CONTACT DETAILS CARD (PHASE 2)
  // ---------------------------------------------------------------------------
  Widget _buildContactDetailsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_support_outlined,
                  color: theme.colorScheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Contact Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 16),

          // Business Name
          _buildContactRow(
            theme,
            icon: Icons.storefront_outlined,
            title: 'Business Name',
            contentWidget: Text(
              'Dripzoid',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 16),

          // Address
          _buildContactRow(
            theme,
            icon: Icons.location_on_outlined,
            title: 'Registered Address',
            contentWidget: Text(
              'Near Cattle Market,\nPithapuram, Andhra Pradesh\nIndia – 533450',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 16),

          // Phone
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _launchPhone(context, _phoneNumber),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _buildContactRow(
                theme,
                icon: Icons.phone_outlined,
                title: 'Phone',
                contentWidget: Text(
                  _phoneNumber,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                trailing: Tooltip(
                  message: 'Call Dripzoid',
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.call_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 16),

          // Privacy Policy Link
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _launchUrl(context, _privacyPolicyUrl),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _buildContactRow(
                theme,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                contentWidget: Text(
                  _privacyPolicyUrl,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Tooltip(
                  message: 'Open Privacy Policy',
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.open_in_new,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required Widget contentWidget,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              contentWidget,
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 14. HELP & FAQ + LICENSES
  // ---------------------------------------------------------------------------
  Widget _buildHelpAndLicenses(ThemeData theme) {
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.help_outline, color: theme.colorScheme.primary),
            title: const Text('Help & FAQ',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Common questions regarding orders & sizing'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFaqModal(context),
          ),
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          ListTile(
            leading:
                Icon(Icons.article_outlined, color: theme.colorScheme.primary),
            title: const Text('Open Source Licenses',
                style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MODALS
  // ---------------------------------------------------------------------------
  void _showSizeGuideModal(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: LayoutUtils.maxFormWidth),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Dripzoid Size Guide',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Our measurements are in inches. Regular street fit across all drops.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Table(
                border: TableBorder.all(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Size',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Chest',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Length',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Shoulder',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  _buildSizeRow('S', '38"', '28"', '18"'),
                  _buildSizeRow('M', '40"', '29"', '19"'),
                  _buildSizeRow('L', '42"', '30"', '20"'),
                  _buildSizeRow('XL', '44"', '31"', '21"'),
                  _buildSizeRow('XXL', '46"', '32"', '22"'),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Got It'),
              ),
            ],
          ),
        );
      },
    );
  }

  TableRow _buildSizeRow(
      String size, String chest, String length, String shoulder) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(size,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(chest, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(length, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(shoulder, textAlign: TextAlign.center),
        ),
      ],
    );
  }

  void _showShippingPolicyModal(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: LayoutUtils.maxFormWidth),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Shipping & Returns Policy',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPolicyItem(
                theme,
                icon: Icons.local_shipping_outlined,
                title: 'Standard Shipping',
                detail:
                    'Dispatched within 24-48 hours. Delivered in 3-5 business days across India.',
              ),
              const SizedBox(height: 14),
              _buildPolicyItem(
                theme,
                icon: Icons.public_outlined,
                title: 'International Shipping',
                detail:
                    'Worldwide courier shipping available with full door-to-door tracking.',
              ),
              const SizedBox(height: 14),
              _buildPolicyItem(
                theme,
                icon: Icons.assignment_return_outlined,
                title: '14-Day Easy Returns',
                detail:
                    'Unused, unwashed garments with tags intact can be returned within 14 days of delivery.',
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPolicyItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFaqModal(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: LayoutUtils.maxFormWidth),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Frequently Asked Questions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFaqTile(
                    theme,
                    q: 'How do I track my order?',
                    a: 'Visit Profile > Orders in the app. Each confirmed order features real-time shipment milestone updates and delivery estimation.',
                  ),
                  _buildFaqTile(
                    theme,
                    q: 'What payment methods do you accept?',
                    a: 'We accept UPI, Credit/Debit cards, NetBanking, digital wallets via Razorpay, and Cash on Delivery (COD).',
                  ),
                  _buildFaqTile(
                    theme,
                    q: 'How do I care for my Dripzoid garments?',
                    a: 'Machine wash cold inside out with similar colors. Line dry in shade to maintain color fastness and print longevity.',
                  ),
                  _buildFaqTile(
                    theme,
                    q: 'Are your drops limited edition?',
                    a: 'Yes, select capsules and creative collabs are limited runs to maintain uniqueness and reduce manufacturing waste.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFaqTile(ThemeData theme,
      {required String q, required String a}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              a,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper container for text sections
  Widget _buildCardSection(
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
