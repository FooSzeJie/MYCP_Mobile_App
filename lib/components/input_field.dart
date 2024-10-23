import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final bool isEmail;
  final bool enabled;
  final int maxlength;
  final bool cannotBeEmpty; // New flag to check if the field is mandatory

  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.isEmail = false,
    this.enabled = true,
    this.maxlength = 100,
    this.cannotBeEmpty = true, // Default to false (optional)
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  String? _errorText; // Error message for validation

  // Validate the field for emptiness
  void _validateInput() {
    setState(() {
      if (widget.cannotBeEmpty && widget.controller.text.isEmpty) {
        _errorText = 'This field cannot be empty';
      } else {
        _errorText = null; // No error if valid
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword,
          enabled: widget.enabled,
          maxLength: widget.maxlength,
          style: TextStyle(
            color: widget.enabled ? Colors.black : Colors.grey,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            // errorText: _errorText, // Display error message
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          onChanged: (_) => _validateInput(), // Validate on input change
        ),

        if (_errorText != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Text(
              _errorText!,
              style: TextStyle(color: Colors.red, fontSize: 15),
            ),
          ),
        ]
      ],
    );
  }
}
