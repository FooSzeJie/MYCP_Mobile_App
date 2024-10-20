import 'package:client/screens/Car/Car_List/car_list.dart';
import 'package:flutter/material.dart';

class CarListScreen extends StatefulWidget {

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
        title: Text(
            "Car List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      // body: CarRegisterForm(),
      body: CarList(),
    );
  }
}
