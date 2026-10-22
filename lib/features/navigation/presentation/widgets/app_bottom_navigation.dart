import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../../wishlist/presentation/providers/wishlist_notifier.dart';
import '../providers/header_notifier.dart';

class AppBottomNavigation extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNavigation({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartCount = ref.watch(cartProvider.select((s) => s.totalItems));
    final wishlistCount = ref.watch(wishlistProvider.select((s) => s.items.length));
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onTap(context, ref, index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          _buildDestination(
            context,
            icon: Icons.favorite_border_rounded,
            selectedIcon: Icons.favorite_rounded,
            label: 'Wishlist',
            badgeCount: wishlistCount,
          ),
          const NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'AskDrip',
          ),
          _buildDestination(
            context,
            icon: Icons.shopping_cart_outlined,
            selectedIcon: Icons.shopping_cart_rounded,
            label: 'Cart',
            badgeCount: cartCount,
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  NavigationDestination _buildDestination(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    int badgeCount = 0,
  }) {
    final theme = Theme.of(context);
    return NavigationDestination(
      icon: Badge(
        label: Text('$badgeCount'),
        isLabelVisible: badgeCount > 0,
        backgroundColor: theme.colorScheme.primary,
        textColor: theme.colorScheme.onPrimary,
        child: Icon(icon),
      ),
      selectedIcon: Badge(
        label: Text('$badgeCount'),
        isLabelVisible: badgeCount > 0,
        backgroundColor: theme.colorScheme.primary,
        textColor: theme.colorScheme.onPrimary,
        child: Icon(selectedIcon),
      ),
      label: label,
    );
  }

  void _onTap(BuildContext context, WidgetRef ref, int index) {
    if (ref.read(headerProvider).isSearchVisible) {
      ref.read(headerProvider.notifier).setSearchVisible(false);
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
