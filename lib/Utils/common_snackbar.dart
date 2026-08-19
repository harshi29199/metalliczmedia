import 'package:flutter/material.dart';

class CommonSnackbar {
  static void showSnackbar(
      BuildContext context,
      String message, {
        Color? color,
        Duration? duration, // Added duration parameter
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration ?? Durations.extralong4, // Use provided duration or default
        padding: const EdgeInsets.symmetric(vertical: 3),
        elevation: 2.0,
        backgroundColor: color ?? Colors.red, // Default background color is red
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message), // No explicit text color, follows theme default
          ],
        ),
      ),
    );
  }
}
