import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/ui/snackbars/premium_snackbar.dart';

class OtpVerificationWidget extends StatefulWidget {
  final String email;
  final Future<bool> Function(String otp) onVerify;
  final Future<void> Function() onResend;

  const OtpVerificationWidget({
    super.key,
    required this.email,
    required this.onVerify,
    required this.onResend,
  });

  @override
  State<OtpVerificationWidget> createState() =>
      _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState
    extends State<OtpVerificationWidget> {
  final TextEditingController otpController =
  TextEditingController();

  int seconds = 60;

  bool loading = false;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    seconds = 60;

    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (seconds == 0) {
          timer.cancel();
        } else {
          setState(() {
            seconds--;
          });
        }
      },
    );
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length != 6) return;

    setState(() {
      loading = true;
    });

    final success =
    await widget.onVerify(otpController.text);

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (!success) {
      PremiumSnackbar.showError(context, "Invalid OTP");
    }
  }

  Future<void> resendOtp() async {
    await widget.onResend();

    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      children: [
        Text(
          "OTP sent to",
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const SizedBox(height: 6),

        Text(
          widget.email,
          style: Theme.of(context)
              .textTheme
              .titleMedium,
        ),

        const SizedBox(height: 32),

        Pinput(
          controller: otpController,
          length: 6,
          onCompleted: (_) => verifyOtp(),
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: loading ? null : verifyOtp,
            child: loading
                ? const CircularProgressIndicator()
                : const Text("Verify OTP"),
          ),
        ),

        const SizedBox(height: 20),

        if (seconds > 0)
          Text(
            "Resend in ${seconds}s",
          )
        else
          TextButton(
            onPressed: resendOtp,
            child: const Text(
              "Resend OTP",
            ),
          ),
      ],
    ),
    );
  }
}