import 'package:client/screens/Car%20Parking/components/car_parking_form.dart';
import 'package:client/screens/Car Parking/components/step_progress_modal.dart';
import 'package:flutter/material.dart';

class CarParkingScreen extends StatefulWidget {
  final String userId;  // Pass the user ID when navigating to HomePage

  const CarParkingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CarParkingScreen> createState() => _CarParkingScreenState();
}

class _CarParkingScreenState extends State<CarParkingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Car Parking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      // body: CarParkingForm(),
      body: StepProgressModal(userId: widget.userId),
    );
  }
}
