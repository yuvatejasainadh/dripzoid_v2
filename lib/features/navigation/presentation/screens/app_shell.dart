import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_header.dart';
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
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerState.isSearchVisible ? 134 : 64),
        child: const AppHeader(),
      ),
      body: navigationShell,
      bottomNavigationBar: AppBottomNavigation(navigationShell: navigationShell),
    );
  }
}
