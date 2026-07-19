import 'package:flutter/material.dart';

class SnackbarHelper {
  const SnackbarHelper._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Colors.green.shade700);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Colors.red.shade700);
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
