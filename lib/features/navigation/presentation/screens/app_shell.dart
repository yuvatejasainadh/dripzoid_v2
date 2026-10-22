import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../../home/presentation/providers/search_notifier.dart';
import '../../../home/presentation/widgets/search_results_view.dart';
import '../../../wishlist/presentation/providers/wishlist_notifier.dart';
import '../widgets/app_bottom_navigation.dart';
import '../providers/header_notifier.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerState = ref.watch(headerProvider);
    final isDesktop = LayoutUtils.isDesktop(context);
    final theme = Theme.of(context);

    return PopScope(
      canPop: !headerState.isSearchVisible,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && headerState.isSearchVisible) {
          ref.read(headerProvider.notifier).clearSearch();
          ref.read(searchProvider.notifier).clearSearch();
        }
      },
      child: isDesktop
          ? _buildDesktopLayout(context, ref, headerState, theme)
          : _buildMobileLayout(context, ref, headerState),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    HeaderState headerState,
    ThemeData theme,
  ) {
    final cartCount = ref.watch(cartProvider.select((s) => s.totalItems));
    final wishlistCount = ref.watch(wishlistProvider.select((s) => s.items.length));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerState.isSearchVisible ? 134 : 64),
        child: const AppHeader(),
      ),
      body: Row(
        children: [
          // Left Navigation Rail for Desktop
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => _onTap(context, ref, index),
            labelType: NavigationRailLabelType.all,
            useIndicator: true,
            indicatorColor: theme.colorScheme.primaryContainer,
            destinations: [
              const NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: _buildBadgeIcon(context, Icons.favorite_border_rounded, wishlistCount),
                selectedIcon: _buildBadgeIcon(context, Icons.favorite_rounded, wishlistCount),
                label: const Text('Wishlist'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome_rounded),
                label: Text('AskDrip'),
              ),
              NavigationRailDestination(
                icon: _buildBadgeIcon(context, Icons.shopping_cart_outlined, cartCount),
                selectedIcon: _buildBadgeIcon(context, Icons.shopping_cart_rounded, cartCount),
                label: const Text('Cart'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: headerState.isSearchVisible
                ? const SearchResultsView()
                : navigationShell,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    HeaderState headerState,
  ) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerState.isSearchVisible ? 134 : 64),
        child: const AppHeader(),
      ),
      body: headerState.isSearchVisible
          ? const SearchResultsView()
          : navigationShell,
      bottomNavigationBar: AppBottomNavigation(navigationShell: navigationShell),
    );
  }

  Widget _buildBadgeIcon(BuildContext context, IconData icon, int count) {
    final theme = Theme.of(context);
    return Badge(
      label: Text('$count'),
      isLabelVisible: count > 0,
      backgroundColor: theme.colorScheme.primary,
      textColor: theme.colorScheme.onPrimary,
      child: Icon(icon),
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
