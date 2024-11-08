import 'package:client/components/confirm_dialog.dart';
import 'package:client/components/timer_control.dart';  // Import TimerControlWidget
import 'package:client/screens/Camera/camera_screen.dart';
import 'package:client/screens/Car%20Parking/Car%20Parking%20Update/car_parking_update_screen.dart';
import 'package:client/screens/Car/Car_List/car_list_screen.dart';
import 'package:client/screens/Home%20Page/components/top_bar.dart';
import 'package:client/screens/Car%20Parking/car_parking_screen.dart';
import 'package:client/screens/Profile/profile_screen.dart';
import 'package:client/screens/transaction/transaction_screen.dart';
import 'package:client/screens/Login/login_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool tenMinuteWarningSent = false;
  Timer? checkTimer;
  String? carParkingId;
  int? remainingDuration; // Track remaining time for the parking session

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
  void initState() {
    super.initState();
    startCheckTimer();
  }

  void startCheckTimer() {
    checkTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      checkParkingTime();
    });
  }

  Future<void> checkParkingTime() async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      final url = Uri.parse('$baseUrl/car_parking/${widget.userId}/status');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('carParking') && data['carParking'].isNotEmpty) {
          final parkingData = data['carParking'][0];
          // final carParkingId = parkingData['_id'];

          if (parkingData.containsKey('end_time')) {
            final endTime = DateTime.parse(parkingData['end_time']).toUtc();
            final now = DateTime.now().toUtc();
            // final remainingDuration = endTime.difference(now).inSeconds;

            setState(() {
              carParkingId = parkingData['_id'];
              remainingDuration = endTime.difference(now).inSeconds;
            });

            if (remainingDuration! <= 600 && remainingDuration! > 598 && !tenMinuteWarningSent) {
              // await _sendSMSNotification("You have 10 minutes left for your car parking.");
              print("10 minutes warning sent.");
              tenMinuteWarningSent = true;  // Prevents further notifications until timer hits 0
            }

            if (remainingDuration! <= 0) { // Parking time over
              // await _sendSMSNotification("Your car parking duration is over.");
              await _terminateTimer(carParkingId!); // Auto terminate parking session
              print("Time's up. Parking session terminated.");
            }
          }
        }
      }
    } catch (error) {
      print('Error checking parking time: $error');
    }
  }

  Future<void> _sendSMSNotification(String message) async {
    final payload = {
      'message': message
    };

    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      final response = await http.post(
        Uri.parse('$baseUrl/car_parking/${widget.userId}/SMS'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        print("SMS error: $errorData");
      }
    } catch (e) {
      print('Error occurred while sending SMS: $e');
    }
  }

  Future<void> _terminateTimer(String carParkingId) async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      final url = Uri.parse('$baseUrl/car_parking/$carParkingId/terminate');
      final response = await http.patch(url);

      if (response.statusCode == 200) {
        print('Parking terminated automatically');
      } else {
        print('Failed to terminate parking: ${response.body}');
      }
    } catch (error) {
      print('Error during termination: $error');
    }
  }

  @override
  void dispose() {
    checkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> catLink = [
      CarParkingScreen(userId: widget.userId),
      CarListScreen(userId: widget.userId),
      TransactionScreen(),
      Camera(),
      ProfileScreen(userId: widget.userId),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Conditionally render TimerControlWidget at the bottom
          if (remainingDuration != null && remainingDuration! > 0)
            TimerControlWidget(
              initialTimeInSeconds: remainingDuration!,
              onExtend: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CarParkingUpdateScreen(userId: widget.userId, carParkingId: carParkingId!)), // Use '!' to assert non-null
                );
              },

              onTerminate: () async {
                // Show confirmation dialog before deleting
                final shouldTerminate = await showConfirmationDialog(
                    context,
                    title: 'Terminate Car Parking',
                    message: 'Are you sure you want to Terminate the car Parking?',
                    button2Text: "Terminate"
                );

                if (shouldTerminate) {
                  await _terminateTimer(carParkingId!); // Handle terminate action
                  setState(() {
                    remainingDuration = null;
                    carParkingId = null;
                  });
                }
              },
            ),
        ],
      ),
    );
  }
}
