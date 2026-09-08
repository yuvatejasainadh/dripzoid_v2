import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class SessionLoaderScreen extends ConsumerStatefulWidget {
  const SessionLoaderScreen({super.key});

  @override
  ConsumerState<SessionLoaderScreen> createState() =>
      _SessionLoaderScreenState();
}

class _SessionLoaderScreenState
    extends ConsumerState<SessionLoaderScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {

      await ref
          .read(authProvider.notifier)
          .checkSession();

      if (!mounted) return;

      final auth = ref.read(authProvider);

      if (auth.status == AuthStatus.authenticated) {
        if (mounted) context.go("/home");
      } else {
        if (mounted) context.go("/login");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}