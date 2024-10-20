import 'package:flutter/material.dart';

// Reusable function for showing dialogs
Future<void> showDialogBox(
    BuildContext context, {
      String title = 'Error',
      required String message,
      String buttonText = 'Close',
    }) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title,
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
        content: Text(message,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(buttonText,
            style: const TextStyle(
              fontSize: 18,
            ),
            ),
          ),
        ],
      );
    },
  );
}
