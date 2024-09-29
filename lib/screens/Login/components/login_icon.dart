import 'package:flutter/material.dart';

class LoginIcon extends StatelessWidget {
  const LoginIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),

      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 120,
      ),
    );
  }
}
