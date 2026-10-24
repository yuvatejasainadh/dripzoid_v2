import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/layout_utils.dart';
import '../providers/auth_provider.dart';
import '../widgets/otp_verification_widget.dart';

class RegisterOtpScreen extends ConsumerWidget {
  final String email;
  const RegisterOtpScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: LayoutUtils.maxFormWidth,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: OtpVerificationWidget(
              email: email,
              onVerify: (otp) async {
                final verified = await ref.read(authProvider.notifier).verifyOTP(email, otp);
                if (verified) {
                  if (context.mounted) {
                    context.pushReplacement('/register-details', extra: email);
                  }
                }
                return verified;
              },
              onResend: () async {
                await ref.read(authProvider.notifier).sendOTP(email);
              },
            ),
          ),
        ),
      ),
    );
  }
}
