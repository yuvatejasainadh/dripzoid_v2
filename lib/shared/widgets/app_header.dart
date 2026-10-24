import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/layout_utils.dart';
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

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: ResponsiveContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main Header Bar
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    // LEFT: DD Logo
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.lg),
                      child: const AppLogo(size: 48),
                    ),

                    const Spacer(),

                    // RIGHT: Actions
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (headerState.isSearchVisible) {
                                ref.read(headerProvider.notifier).clearSearch();
                                ref.read(searchProvider.notifier).clearSearch();
                              } else {
                                ref.read(headerProvider.notifier).setSearchVisible(true);
                              }
                            },
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
                  ],
                ),
              ),

              Flexible(
                fit: FlexFit.loose,
                child: ClipRect(
                  child: AnimatedSize(
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
                                onSubmitted: (v) {
                                  ref.read(headerProvider.notifier).updateSearchQuery(v);
                                  ref.read(searchProvider.notifier).submitQuery(v);
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
