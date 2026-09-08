import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_logo.dart';
import 'notification_badge.dart';
import 'header_search_bar.dart';
import '../../features/navigation/presentation/providers/navigation_notifier.dart';
import '../../features/navigation/presentation/providers/header_notifier.dart';
import '../../features/home/presentation/providers/search_notifier.dart';
import '../../core/theme/tokens/app_spacing.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerState = ref.watch(headerProvider);
    final navState = ref.watch(navigationProvider);
    final theme = Theme.of(context);
    
    // Width for side sections to ensure branding remains perfectly centered
    const sideWidth = 100.0;

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main Header Bar
            SizedBox(
              height: 64,
              child: Row(
                children: [
                  // LEFT: DD Logo
                  SizedBox(
                    width: sideWidth,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.lg),
                        child: const AppLogo(size: 48),
                      ),
                    ),
                  ),

                  // CENTER: Branding
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'DRIPZOID',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Wear The Confidence',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // RIGHT: Actions
                  SizedBox(
                    width: sideWidth,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => ref.read(headerProvider.notifier).toggleSearch(),
                              icon: Icon(
                                headerState.isSearchVisible 
                                    ? Icons.close_rounded 
                                    : Icons.search_rounded,
                                size: 24,
                              ),
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Search',
                            ),
                            NotificationBadge(
                              count: navState.notificationCount,
                              child: IconButton(
                                onPressed: () {
                                  // TODO: Navigate to Notifications
                                },
                                icon: const Icon(Icons.notifications_none_rounded, size: 24),
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Notifications',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: double.infinity,
                height: headerState.isSearchVisible ? 70 : 0,
                child: headerState.isSearchVisible
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HeaderSearchBar(
                          initialValue: headerState.searchQuery,
                          onChanged: (v) {
                            ref.read(headerProvider.notifier).updateSearchQuery(v);
                            ref.read(searchProvider.notifier).onQueryChanged(v);
                          },
                          onClear: () {
                            ref.read(headerProvider.notifier).updateSearchQuery('');
                            ref.read(searchProvider.notifier).clearSearch();
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
