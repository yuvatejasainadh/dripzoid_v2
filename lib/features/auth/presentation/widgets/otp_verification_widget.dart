import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/ui/dialogs/app_error_dialog.dart';

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
  final TextEditingController otpController = TextEditingController();

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
          if (mounted) {
            setState(() {
              seconds--;
            });
          }
        }
      },
    );
  }

  Future<void> verifyOtp() async {
    if (loading || otpController.text.length != 6) return;

    setState(() {
      loading = true;
    });

    try {
      final success = await widget.onVerify(otpController.text);
      if (!mounted) return;

      if (!success) {
        AppErrorDialog.showForError(
          context,
          error: "Invalid or expired OTP. Please verify the code and try again.",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> resendOtp() async {
    if (seconds > 0) return;
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
            style: Theme.of(context).textTheme.titleMedium,
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
            height: 50,
            child: FilledButton(
              onPressed: loading ? null : verifyOtp,
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Verify OTP"),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: seconds == 0 ? resendOtp : null,
            child: Text(
              seconds == 0 ? "Resend OTP" : "Resend in $seconds s",
            ),
          ),
        ],
      ),
    );
  }
}
