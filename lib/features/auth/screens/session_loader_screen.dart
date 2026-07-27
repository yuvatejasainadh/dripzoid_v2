import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/session_provider.dart';

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
          .read(sessionProvider.notifier)
          .initialize();

      if (!mounted) return;

      final session = ref.read(sessionProvider);

      if (session.authenticated) {
        Navigator.pushReplacementNamed(
          context,
          "/home",
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          "/login",
        );
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