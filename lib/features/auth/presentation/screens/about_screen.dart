import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/app_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Dripzoid'),
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: AppLogo(size: 100),
                ),
                const SizedBox(height: 24),
                Text(
                  'Dripzoid',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version ${info?.version ?? '1.0.0'} (${info?.buildNumber ?? '1'})',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 48),
                _buildAboutTile(
                  context,
                  title: 'Privacy Policy',
                  onTap: () => _launchUrl('https://dripzoid.com/privacy'),
                ),
                _buildAboutTile(
                  context,
                  title: 'Terms & Conditions',
                  onTap: () => _launchUrl('https://dripzoid.com/terms'),
                ),
                _buildAboutTile(
                  context,
                  title: 'Licenses',
                  onTap: () => showLicensePage(context: context),
                ),
                const SizedBox(height: 60),
                Text(
                  '© 2026 Dripzoid Inc.\nAll rights reserved.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context, {required String title, required VoidCallback onTap}) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: onTap,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
