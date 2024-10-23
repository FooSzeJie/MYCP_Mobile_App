import 'package:client/screens/Car/Car_Edit/car_edit_form.dart';
import 'package:client/screens/Car/components/car.dart';  // Import the Car model
import 'package:flutter/material.dart';

class CarEditScreen extends StatefulWidget {

  final String userId;  // Pass the user ID when navigating to HomePage
  final Car car;  // Pass the Car object

  const CarEditScreen({Key? key, required this.userId, required this.car}) : super(key: key);  // Constructor with userId

  @override
  State<CarEditScreen> createState() => _CarEditScreen();
}

class _CarEditScreen extends State<CarEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Car Edit",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      // body: CarRegisterForm(),
      body: CarEditForm(userId: widget.userId, car: widget.car,),
    );
  }
}
