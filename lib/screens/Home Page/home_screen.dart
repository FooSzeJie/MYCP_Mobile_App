import 'package:client/screens/Camera/camera_screen.dart';
import 'package:client/screens/Home%20Page/components/top_bar.dart';
import 'package:client/screens/Car%20Register/car_register_screen.dart';
import 'package:client/screens/Car%20Parking/car_parking_screen.dart';
import 'package:client/screens/Profile/profile_screen.dart';
import 'package:client/screens/transaction/transaction_screen.dart';
import 'package:client/screens/Login/login_screen.dart'; // Import the LoginScreen
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
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

  List<Widget> catLink = [
    CarParkingScreen(),
    CarRegisterScreen(),
    TransactionScreen(),
    Camera(),
    ProfileScreen(),
    // Notice that the Logout action will be handled separately, not here.
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          TopBar(),
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
                        // Check if the clicked item is "Logout"
                        if (catNames[index] == "Logout") {
                          // Perform logout and navigate back to the login screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        } else {
                          // Navigate to the selected screen
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
