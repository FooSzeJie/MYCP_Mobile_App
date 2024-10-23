import 'package:flutter/material.dart';

// Function to show a delete confirmation dialog
Future<bool> showConfirmationDialog(BuildContext context, {
  required String title,
  required String message,
  String button1Text = "Cancel",  // Default button text
  String button2Text = "Delete",   // Default button text
}) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontSize: 24),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 24),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // Return false for Cancel
          child: Text(
            button1Text,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true), // Return true for Delete
          child: Text(
            button2Text,
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      ],
    ),
  ) ?? false; // Return false if dialog is dismissed without an action
}
