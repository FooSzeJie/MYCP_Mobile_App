import 'package:client/screens/Camera/camera_screen.dart';
import 'package:client/screens/Car/Car_List/car_list_screen.dart';
import 'package:client/screens/Home%20Page/components/top_bar.dart';
import 'package:client/screens/Car%20Parking/car_parking_screen.dart';
import 'package:client/screens/Profile/profile_screen.dart';
import 'package:client/screens/transaction/transaction_screen.dart';
import 'package:client/screens/Login/login_screen.dart'; // Import the LoginScreen
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String userId;  // Pass the user ID when navigating to HomePage

  const HomePage({Key? key, required this.userId}) : super(key: key);  // Constructor with userId

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Creating static data in list
  List<String> catNames = [
    "Car Parking",
    "Car Register",
    "Transaction",
    "Scan",
    "Profile",
    "Logout",
  ];

  List<Color> catColors = [
    Color(0xFFFFCF2F),
    Color(0xFF6FE08D),
    Color(0xFF618DFD),
    Color(0xFFFC7F7F),
    Color(0xFFCB84FB),
    Color(0xFF78E667),
  ];

  List<Icon> catIcon = [
    Icon(Icons.car_repair, color: Colors.white, size: 50),
    Icon(Icons.car_rental, color: Colors.white, size: 50),
    Icon(Icons.assignment, color: Colors.white, size: 50),
    Icon(Icons.camera, color: Colors.white, size: 50),
    Icon(Icons.person, color: Colors.white, size: 50),
    Icon(Icons.logout, color: Colors.white, size: 50),
  ];

  @override
  Widget build(BuildContext context) {
      // Create the list of screens inside the build method, where widget.userId is available
      List<Widget> catLink = [
        CarParkingScreen(),
        CarListScreen(userId: widget.userId),
        TransactionScreen(),
        Camera(),
        ProfileScreen(userId: widget.userId),
      ];

    return Scaffold(
      body: ListView(
        children: [
          // Pass the userId to TopBar
          TopBar(userId: widget.userId),
          Padding(
            padding: EdgeInsets.only(top: 20, left: 15, right: 15),
            child: Column(
              children: [
                GridView.builder(
                  itemCount: catNames.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        // Handle Logout action
                        if (catNames[index] == "Logout") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => catLink[index],
                            ),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10, top: 10),
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: catColors[index],
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: catIcon[index],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            catNames[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
