import 'package:client/screens/Car%20Parking/components/car_parking_form.dart';
import 'package:flutter/material.dart';

class CarParkingScreen extends StatefulWidget {
  const CarParkingScreen({super.key});

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
        title: Text(
          "Car Parking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      body: CarParkingForm(),
    );
  }
}
