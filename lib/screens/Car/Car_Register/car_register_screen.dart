import 'package:client/screens/Car/Car_Register/car_register_form.dart';
import 'package:flutter/material.dart';

class CarRegisterScreen extends StatefulWidget {
  final String userId;  // Pass the user ID when navigating to HomePage

  const CarRegisterScreen({Key? key, required this.userId}) : super(key: key);  // Constructor with userId

  @override
  State<CarRegisterScreen> createState() => _CarRegisterScreenState();
}

class _CarRegisterScreenState extends State<CarRegisterScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Car Register",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: CarRegisterForm(userId: widget.userId)
    );
  }
}
