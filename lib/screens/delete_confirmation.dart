import 'package:flutter/material.dart';

class DeleteConfirmation {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String cancelText = 'Cancel',
    String deleteText = 'Delete',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // REQUIRED
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(deleteText, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return result == true;
  }
}