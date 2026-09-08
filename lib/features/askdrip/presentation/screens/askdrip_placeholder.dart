import 'package:flutter/material.dart';

class AskDripPlaceholder extends StatelessWidget {
  const AskDripPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('AskDrip AI Assistant', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Your conversational fashion expert is coming soon.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
