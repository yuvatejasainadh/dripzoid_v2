import 'package:flutter/material.dart';

class LoginRequiredDialog {
  static Future<void> show(
      BuildContext context,
      ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "Login Required",
          ),

          content: const Text(
            "Please login to continue.",
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushNamed(
                  context,
                  "/login",
                );
              },
              child: const Text("Login"),
            ),
          ],
        );
      },
    );
  }
}