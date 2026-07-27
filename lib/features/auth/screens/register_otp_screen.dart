import 'package:flutter/material.dart';

import '../widgets/otp_verification_widget.dart';

class RegisterOtpScreen extends StatelessWidget {
  const RegisterOtpScreen({
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
              // TODO:
              // POST Verify OTP API

              Navigator.pushReplacementNamed(
                context,
                "/register-details",
                arguments: email,
              );

              return true;
            },

            onResend: () async {
              // TODO:
              // Resend OTP API
            },
          ),
        ),
      ),
    );
  }
}