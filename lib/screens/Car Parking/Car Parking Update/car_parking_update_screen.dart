import 'package:client/screens/Car%20Parking/Car%20Parking%20Update/car_parking_update_form.dart';
import 'package:flutter/material.dart';

class CarParkingUpdateScreen extends StatefulWidget {
  final String userId; // Pass the user ID when navigating to HomePage
  final String carParkingId;

  const CarParkingUpdateScreen({Key? key, required this.userId, required this.carParkingId}) : super(key: key);

  @override
  State<CarParkingUpdateScreen> createState() => _CarParkingUpdateScreenState();
}

class _CarParkingUpdateScreenState extends State<CarParkingUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Extend Car Parking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: CarParkingUpdateForm(userId: widget.userId, carParkingId: widget.carParkingId));
  }
}
