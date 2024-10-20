import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final bool isEmail;
  final bool enabled;

  const InputField({super.key, required this.controller, required this.hintText, this.isPassword= false, this.isEmail = false, this.enabled = true});

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword,
      enabled: widget.enabled,
      style: TextStyle(color: widget.enabled ? Colors.black : Colors.grey),
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
