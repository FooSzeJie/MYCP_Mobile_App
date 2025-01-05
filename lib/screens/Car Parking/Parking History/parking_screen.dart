import 'package:client/screens/Car%20Parking/Parking%20History/parking_list.dart';
import 'package:flutter/material.dart';

class ParkingScreen extends StatefulWidget {
  final String userId;  // Pass the user ID when navigating to HomePage

  const ParkingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ParkingScreen> createState() => _ParkingScreenScreenState();
}

class _ParkingScreenScreenState extends State<ParkingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Car Parking History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      body: ParkingList(userId: widget.userId),
    );
  }
}

