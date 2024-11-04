import 'package:client/screens/Car/Car_List/car_list.dart';
import 'package:client/screens/Home%20Page/home_screen.dart';
import 'package:flutter/material.dart';

class CarListScreen extends StatefulWidget {

  final String userId;  // Pass the user ID when navigating to HomePage

  const CarListScreen({Key? key, required this.userId}) : super(key: key);  // Constructor with userId

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
            "Car List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          // Navigate to a specific page when the back button is pressed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userId: widget.userId), // Replace `HomePage` with your desired page
            ),
          );
        },
      ),
    ),

      // body: CarRegisterForm(),
      body: CarList(userId: widget.userId),
    );
  }
}
