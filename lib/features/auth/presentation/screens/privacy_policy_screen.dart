import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/layout_utils.dart';
import '../../../../core/ui/snackbars/premium_snackbar.dart';

/// Minimal, readable, and responsive native Privacy Policy screen for Dripzoid.
///
/// Embodies the Dripzoid monochrome street-luxury identity while providing comprehensive,
/// transparent disclosures under applicable Indian regulations (DPDP Act, IT Rules).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  /// Official web policy URL preserved as an informative reference.
  static const String webPolicyUrl =
      'https://dripzoid-frontend.onrender.com/privacy-policy';

  static const String customerSupportPhone = '+91 94940 38163';
  static const String contactEmail = 'dripzoidapp@gmail.com';
  static const String privacyEmail = contactEmail;
  static const String supportEmail = contactEmail;
  static const String registeredAddress =
      'Near Cattle Market, Pithapuram, Andhra Pradesh, India – 533450';
  static const String lastUpdatedDate = '22 October 2026';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Banner
              _buildHeader(theme, textTheme),
              const SizedBox(height: 20),

              // 2. Official Web Reference Card
              _buildWebReferenceCard(context, theme),
              const SizedBox(height: 24),

              // 3. Section 1: Introduction & Operational Scope
              _buildSectionCard(
                theme,
                icon: Icons.info_outline,
                title: '1. Introduction & Operational Scope',
                children: [
                  Text(
                    'Dripzoid is an Indian streetwear apparel brand based in Andhra Pradesh, India. We are dedicated to providing premium minimal clothing while respecting and safeguarding your personal privacy.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This Privacy Policy describes how we collect, use, store, share, and protect your information when you interact with our mobile application, digital storefront, and customer services. Our operations comply with applicable Indian legal frameworks, including the Digital Personal Data Protection Act, 2023 (DPDP Act) and the Information Technology Rules.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Dripzoid operates in India and serves customers exclusively across India. By using our application, you acknowledge the data collection and processing practices described herein.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Section 2: Information We Collect
              _buildSectionCard(
                theme,
                icon: Icons.assignment_outlined,
                title: '2. Information We Collect',
                children: [
                  Text(
                    'We collect only the information necessary to fulfill your orders, protect against fraud, and deliver a smooth streetwear shopping experience:',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSubheading(theme, 'A. Personal Information You Provide:'),
                  const SizedBox(height: 6),
                  _buildBullet(theme, 'Identity & Contact',
                      'Full name, mobile telephone number, and email address.'),
                  _buildBullet(theme, 'Delivery & Billing',
                      'Street address, house/flat number, landmark, city, state, and postal PIN code.'),
                  _buildBullet(theme, 'Account Credentials',
                      'Encrypted password hashes and active session authentication tokens.'),
                  _buildBullet(theme, 'Support Interactions',
                      'Messages, garment sizing queries, and feedback submitted to our customer care team.'),
                  const SizedBox(height: 14),
                  _buildSubheading(theme, 'B. Payment Information (Secure Gateway):'),
                  const SizedBox(height: 6),
                  Text(
                    'All digital payments (UPI, Credit/Debit Cards, NetBanking, Wallets) are processed directly through authorized, RBI-licensed and PCI-DSS Level 1 compliant payment aggregators (such as Razorpay).',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildHighlightBox(
                    theme,
                    icon: Icons.lock_outline,
                    text:
                        'Important: Dripzoid does not collect, receive, or store full credit/debit card numbers, CVVs, or UPI PINs on its own servers.',
                  ),
                  const SizedBox(height: 14),
                  _buildSubheading(theme, 'C. Technical & Diagnostic Information:'),
                  const SizedBox(height: 6),
                  _buildBullet(theme, 'Device Specifications',
                      'Hardware model, operating system version, and installed app build number.'),
                  _buildBullet(theme, 'Network Diagnostics',
                      'IP address, network connection status, and approximate city-level location derived from IP.'),
                  _buildBullet(theme, 'Performance Analytics',
                      'Anonymous crash logs, response latencies, and interaction metrics used to maintain app stability.'),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Section 3: How We Use Your Information
              _buildSectionCard(
                theme,
                icon: Icons.tune_outlined,
                title: '3. How We Use Your Information',
                children: [
                  _buildBullet(theme, 'Order Processing & Delivery',
                      'Validating order items, verifying stock reservations, generating GST invoices, and dispatching shipments across India.'),
                  _buildBullet(theme, 'Account Administration',
                      'Authenticating logins, managing saved delivery addresses, and securing profile details.'),
                  _buildBullet(theme, 'Customer Support',
                      'Resolving order inquiries, delivery updates, and returns or sizing questions.'),
                  _buildBullet(theme, 'Order Notifications',
                      'Transmitting essential transactional SMS, email, or in-app notifications regarding shipment milestones and delivery status.'),
                  _buildBullet(theme, 'Security & Fraud Prevention',
                      'Monitoring for unauthorized transactions, bot activity, and duplicate orders.'),
                  _buildBullet(theme, 'Platform Optimization',
                      'Analyzing aggregated, anonymized trends to refine UI responsiveness, search relevancy, and inventory stocking.'),
                  _buildBullet(theme, 'Promotional Updates',
                      'Sending curated drop announcements only when explicit opt-in consent is provided. You may opt out at any time with a single tap.'),
                ],
              ),
              const SizedBox(height: 16),

              // 6. Section 4: Legal Basis for Processing
              _buildSectionCard(
                theme,
                icon: Icons.gavel_outlined,
                title: '4. Legal Basis for Processing',
                children: [
                  Text(
                    'Under applicable Indian laws including the DPDP Act, we process your personal data under the following legitimate grounds:',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildBullet(theme, 'Performance of Contract',
                      'Required to process purchases, confirm inventory, and deliver products to your doorstep.'),
                  _buildBullet(theme, 'Statutory Compliance',
                      'Fulfilling mandatory tax invoicing, accounting, and consumer protection regulations in India.'),
                  _buildBullet(theme, 'Legitimate Business Interests',
                      'Protecting user accounts from fraudulent access, maintaining server reliability, and securing payments.'),
                  _buildBullet(theme, 'User Consent',
                      'Required for non-essential communications, marketing notifications, and optional profile features.'),
                ],
              ),
              const SizedBox(height: 16),

              // 7. Section 5: Third-Party Sharing & Disclosure
              _buildSectionCard(
                theme,
                icon: Icons.share_outlined,
                title: '5. Third-Party Sharing & Disclosure',
                children: [
                  _buildHighlightBox(
                    theme,
                    icon: Icons.verified_user_outlined,
                    text:
                        'Strict Policy: Dripzoid never sells, rents, or trades your personal data to any third party for marketing or commercial purposes.',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We share personal data strictly on a need-to-know basis with trusted partners who assist in our operations:',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildBullet(theme, 'Logistics & Courier Partners',
                      'Recipient name, delivery address, and contact number are shared strictly with certified delivery partners to fulfill shipments across India.'),
                  _buildBullet(theme, 'Payment Processors',
                      'Order totals and transaction reference identifiers are securely transmitted to RBI-authorized payment gateways to process transactions.'),
                  _buildBullet(theme, 'Cloud & Infrastructure Services',
                      'Hosted on secure cloud environments with end-to-end encryption for storage and computing.'),
                  _buildBullet(theme, 'Legal & Regulatory Mandates',
                      'Disclosed only when strictly required by a court order, law enforcement summons, or applicable Indian statutory obligation.'),
                ],
              ),
              const SizedBox(height: 16),

              // 8. Section 6: Cookies & Tracking Technologies
              _buildSectionCard(
                theme,
                icon: Icons.cookie_outlined,
                title: '6. Cookies & Tracking Technologies',
                children: [
                  _buildSubheading(theme, 'Native Mobile Application:'),
                  const SizedBox(height: 6),
                  Text(
                    'The Dripzoid Flutter mobile app does NOT use browser cookies. Instead, it utilizes secure local device storage (SharedPreferences / secure storage) solely for essential app operations: keeping you authenticated, remembering your theme preference (Dark/Light mode), and caching temporary catalog data for speed.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSubheading(theme, 'Web Storefront:'),
                  const SizedBox(height: 6),
                  Text(
                    'When accessing our digital services via a web browser, standard session cookies and anonymous analytics cookies may be utilized solely to preserve active shopping cart sessions and analyze aggregated web traffic.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 9. Section 7: Data Retention & Storage
              _buildSectionCard(
                theme,
                icon: Icons.hourglass_empty_outlined,
                title: '7. Data Retention & Storage',
                children: [
                  Text(
                    'We retain your personal data only as long as necessary to achieve the purposes outlined in this policy:',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildBullet(theme, 'Active Accounts',
                      'Your profile details and address records remain saved as long as your account is active.'),
                  _buildBullet(theme, 'Financial & Tax Records',
                      'In accordance with Indian tax laws (such as GST regulations), order records, invoices, and transaction histories are retained for the legally prescribed statutory duration (typically 5 to 7 years).'),
                  _buildBullet(theme, 'Account Closure',
                      'Upon receiving a validated account deletion request, personal identifying data is permanently erased or irreversibly anonymized, except where statutory retention is legally mandated.'),
                ],
              ),
              const SizedBox(height: 16),

              // 10. Section 8: Security Safeguards
              _buildSectionCard(
                theme,
                icon: Icons.security_outlined,
                title: '8. Security Safeguards',
                children: [
                  _buildBullet(theme, 'Transport Encryption',
                      'All communications between the mobile application and our backend are encrypted using Transport Layer Security (TLS 1.2 / TLS 1.3).'),
                  _buildBullet(theme, 'Access Controls',
                      'Role-based access restrictions and administrative authentication safeguard our backend systems.'),
                  _buildBullet(theme, 'Credential Protection',
                      'User passwords are cryptographically salted and hashed. Cleartext credentials are never saved.'),
                  _buildBullet(theme, 'Standard Security Qualification',
                      'While we maintain robust, industry-standard administrative, physical, and technical safeguards, no electronic transmission over the internet or storage method is 100% impenetrable.'),
                ],
              ),
              const SizedBox(height: 16),

              // 11. Section 9: Your Rights & Choices
              _buildSectionCard(
                theme,
                icon: Icons.manage_accounts_outlined,
                title: '9. Your Rights & Choices',
                children: [
                  Text(
                    'Under applicable Indian data protection laws, you enjoy meaningful control over your personal data:',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildBullet(theme, 'Right to Access',
                      'Review your saved profile information, addresses, and order history directly in the app.'),
                  _buildBullet(theme, 'Right to Rectification',
                      'Update or correct inaccurate contact details and delivery addresses via Account Settings.'),
                  _buildBullet(theme, 'Right to Erasure / Deletion',
                      'Request deletion of your account and associated personal data by contacting our privacy team.'),
                  _buildBullet(theme, 'Marketing Opt-Out',
                      'Unsubscribe from non-essential promotional communications at any time.'),
                  _buildBullet(theme, 'Grievance Redressal',
                      'Submit inquiries or complaints directly to our Grievance Officer for prompt resolution.'),
                ],
              ),
              const SizedBox(height: 16),

              // 12. Section 10: Children's Privacy
              _buildSectionCard(
                theme,
                icon: Icons.escalator_warning_outlined,
                title: "10. Children's Privacy",
                children: [
                  Text(
                    'Dripzoid services and mobile applications are designed for individuals who are at least 16 years of age (or the age of legal majority under Indian law).',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We do not knowingly collect personal identifiable information from children under 16 without parental or guardian consent. If we learn that personal data of a minor has been collected without verifiable consent, we will promptly delete such data from our records.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Note: Age threshold is subject to ongoing statutory alignment with the DPDP Act guidelines.',
                    style: textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 13. Section 11: International Data Transfers
              _buildSectionCard(
                theme,
                icon: Icons.public_outlined,
                title: '11. International Data Transfers',
                children: [
                  Text(
                    'Dripzoid operates in India and serves customers across India. Data is processed primarily on secure cloud servers located within or compliant with Indian data governance requirements.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Where multi-region cloud service providers are utilized, cross-border transfers are governed by standard contractual clauses and rigorous technical encryption safeguards adhering to applicable Indian regulations.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 14. Section 12: Policy Updates & Notifications
              _buildSectionCard(
                theme,
                icon: Icons.update_outlined,
                title: '12. Policy Updates & Notifications',
                children: [
                  Text(
                    'We may modify or update this Privacy Policy from time to time to reflect modifications in our business practices, app features, or legal requirements.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When updates occur, we will revise the "Last updated" date at the top of this screen. For material updates, we may notify you through in-app notices or push notifications. Continued use of our mobile app indicates your acknowledgment of the revised terms.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 15. Section 13: Contact & Grievance Redressal
              _buildContactSection(context, theme, textTheme),
              const SizedBox(height: 20),

              // 16. Section 14: Closing Commitment Banner
              _buildClosingBanner(theme, textTheme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.privacy_tip_outlined,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'DRIPZOID PRIVACY POLICY',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Last updated: $lastUpdatedDate',
              style: textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We value your trust and are committed to safeguarding your personal data with transparency, rigor, and respect across our mobile app and Indian e-commerce operations.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebReferenceCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.language_outlined,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Official Web Reference',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  webPolicyUrl,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Copy link',
            icon: const Icon(Icons.copy_outlined, size: 18),
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: webPolicyUrl));
              if (context.mounted) {
                PremiumSnackbar.showSuccess(
                  context,
                  'Privacy Policy URL copied to clipboard',
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
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
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubheading(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildBullet(ThemeData theme, String boldPrefix, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
                children: [
                  TextSpan(
                    text: '$boldPrefix: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox(ThemeData theme,
      {required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(
      BuildContext context, ThemeData theme, TextTheme textTheme) {
    return Container(
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
              Icon(Icons.headset_mic_outlined,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '13. Contact & Grievance Redressal',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'If you have questions, concerns, or requests regarding this Privacy Policy or your personal data, reach out to our team:',
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),

          // Business Details
          _buildContactTile(
            theme,
            icon: Icons.business_outlined,
            title: 'Business Entity',
            subtitle: 'Dripzoid',
          ),
          const SizedBox(height: 10),

          // Address with copy
          _buildContactTile(
            theme,
            icon: Icons.location_on_outlined,
            title: 'Registered Address',
            subtitle: registeredAddress,
            actionIcon: Icons.copy_outlined,
            actionTooltip: 'Copy Address',
            onAction: () async {
              await Clipboard.setData(
                  const ClipboardData(text: registeredAddress));
              if (context.mounted) {
                PremiumSnackbar.showSuccess(
                  context,
                  'Address copied to clipboard',
                );
              }
            },
          ),
          const SizedBox(height: 10),

          // Phone with dialer
          _buildContactTile(
            theme,
            icon: Icons.phone_outlined,
            title: 'Customer Care Phone',
            subtitle: customerSupportPhone,
            actionIcon: Icons.call_outlined,
            actionTooltip: 'Call Support',
            onAction: () async {
              final cleanPhone =
                  customerSupportPhone.replaceAll(RegExp(r'[^\d+]'), '');
              final uri = Uri.parse('tel:$cleanPhone');
              try {
                final launched = await launchUrl(uri);
                if (!launched && context.mounted) {
                  PremiumSnackbar.showError(
                      context, 'Could not dial $customerSupportPhone');
                }
              } catch (_) {
                if (context.mounted) {
                  PremiumSnackbar.showError(
                      context, 'Could not dial $customerSupportPhone');
                }
              }
            },
          ),
          const SizedBox(height: 10),

          // Contact Email with mailto
          _buildContactTile(
            theme,
            icon: Icons.email_outlined,
            title: 'Contact Email',
            subtitle: contactEmail,
            actionIcon: Icons.email_outlined,
            actionTooltip: 'Email Support & Privacy',
            onAction: () async {
              final uri = Uri.parse('mailto:$contactEmail');
              try {
                final launched = await launchUrl(uri);
                if (!launched && context.mounted) {
                  PremiumSnackbar.showError(
                      context, 'Could not open mail for $contactEmail');
                }
              } catch (_) {
                if (context.mounted) {
                  PremiumSnackbar.showError(
                      context, 'Could not open mail for $contactEmail');
                }
              }
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Response Time: We strive to acknowledge and address all inquiries or grievance requests within 30 days as prescribed by applicable Indian regulations.',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    IconData? actionIcon,
    String? actionTooltip,
    VoidCallback? onAction,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAction,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (actionIcon != null && onAction != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(actionIcon, size: 18),
                  tooltip: actionTooltip,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClosingBanner(ThemeData theme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            'WEAR THE CONFIDENCE',
            textAlign: TextAlign.center,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '“At Dripzoid, our commitment is simple: Wear The Confidence with complete peace of mind. We protect your privacy as passionately as we craft our streetwear.”',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
