import 'package:flutter/material.dart';

import '../widgets/otp_verification_widget.dart';

class ForgotOtpScreen extends StatelessWidget {
  const ForgotOtpScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final email =
    ModalRoute.of(context)!.settings.arguments
    as String;

    return Scaffold(
      appBar: AppBar(),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: OtpVerificationWidget(
            email: email,

            onVerify: (otp) async {

              // TODO
              // Verify Forgot Password OTP

              Navigator.pushReplacementNamed(
                context,
                "/reset-password",
                arguments: email,
              );

              return true;
            },

            onResend: () async {

              // TODO
              // Resend Forgot Password OTP

            },
          ),
        ),
      ),
    );
  }
}