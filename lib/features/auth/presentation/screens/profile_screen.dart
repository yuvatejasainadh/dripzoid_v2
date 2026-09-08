import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_notifier.dart';
import '../widgets/profile_quick_action_card.dart';
import '../../../../core/ui/dialogs/premium_alert.dart';
import '../../../../core/theme/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      await ref.read(profileProvider.notifier).uploadAvatar(image.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final theme = Theme.of(context);
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // User Header
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(ref),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.outline, width: 1),
                      ),
                      child: profileState.isLoading
                          ? const CircleAvatar(
                              radius: 56,
                              child: CircularProgressIndicator(),
                            )
                          : CircleAvatar(
                              radius: 56,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              backgroundImage: user?.avatar != null
                                  ? CachedNetworkImageProvider(user!.avatar!)
                                  : null,
                              child: user?.avatar == null
                                  ? Text(
                                      (user?.name ?? 'U')[0].toUpperCase(),
                                      style: theme.textTheme.displayMedium?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(Icons.camera_alt, size: 18, color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Premium User',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? '',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Quick Action Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ProfileQuickActionCard(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Orders',
                    subtitle: 'Track your orders',
                    onTap: () => context.push('/profile/orders'),
                  ),
                  const SizedBox(width: 16),
                  ProfileQuickActionCard(
                    icon: Icons.favorite_border,
                    title: 'Wishlist',
                    subtitle: 'Saved items',
                    onTap: () => context.push('/wishlist'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(context, 'Personal Details', [
              _buildDetailItem(
                context, 
                icon: Icons.phone_android_outlined, 
                label: 'Mobile', 
                value: user?.phone ?? 'Not added',
              ),
              _buildDetailItem(
                context, 
                icon: Icons.person_outline_rounded, 
                label: 'Gender', 
                value: user?.gender != null 
                    ? user!.gender![0].toUpperCase() + user.gender!.substring(1) 
                    : 'Not added',
              ),
              _buildDetailItem(
                context, 
                icon: Icons.cake_outlined, 
                label: 'Birthday', 
                value: user?.dob != null 
                    ? DateFormat('dd MMM yyyy').format(user!.dob!) 
                    : 'Not added',
              ),
            ]),

            _buildSection(context, 'Account Settings', [
              _buildMenuItem(
                context,
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => context.push('/profile/edit'),
              ),
              _buildMenuItem(
                context,
                icon: Icons.location_on_outlined,
                title: 'Saved Addresses',
                onTap: () => context.push('/profile/addresses'),
              ),
              _buildThemeSelector(context, ref),
            ]),

            _buildSection(context, 'Security', [
              _buildMenuItem(
                context,
                icon: Icons.security_outlined,
                title: 'Change Password',
                onTap: () => context.push('/profile/security'),
              ),
            ]),

            _buildSection(context, 'Support', [
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () {},
              ),
            ]),

            _buildSection(context, 'App Info', [
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: 'About Dripzoid',
                onTap: () => context.push('/profile/about'),
              ),
            ]),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await PremiumAlert.confirm(
                    context,
                    title: 'Sign out?',
                    message: 'Are you sure you want to sign out of your account?',
                    confirmText: 'Sign Out',
                    isDestructive: true,
                  );

                  if (confirmed) {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 16),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: value == 'Not added' ? theme.colorScheme.outline : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(themeProvider);
    return ListTile(
      leading: const Icon(Icons.dark_mode_outlined, size: 22),
      title: const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w500)),
      trailing: DropdownButton<ThemeSelection>(
        value: selection,
        underline: const SizedBox(),
        onChanged: (val) {
          if (val != null) {
            ref.read(themeProvider.notifier).setTheme(val);
          }
        },
        items: const [
          DropdownMenuItem(value: ThemeSelection.system, child: Text('System')),
          DropdownMenuItem(value: ThemeSelection.light, child: Text('Light')),
          DropdownMenuItem(value: ThemeSelection.dark, child: Text('Dark')),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
