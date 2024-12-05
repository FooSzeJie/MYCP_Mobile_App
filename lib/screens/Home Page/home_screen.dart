import 'package:client/components/confirm_dialog.dart';
import 'package:client/components/timer_control.dart'; // Import TimerControlWidget
import 'package:client/screens/Saman/Camera/saman_camera.dart';
import 'package:client/screens/Saman/Saman%20List/saman_list_screen.dart';
import "package:client/screens/Saman/saman_screen.dart";
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
  final ValueNotifier<int?> remainingDurationNotifier = ValueNotifier(null); // Optimized state management
  Timer? checkTimer;
  String? carParkingId;
  bool tenMinuteWarningSent = false;

  List<String> catNames = [
    "Car Parking",
    "Car Register",
    "Transaction",
    "Saman",
    "Saman List",
    "Profile",
    "Logout",
  ];

  List<Color> catColors = [
    const Color(0xFFFFCF2F),
    const Color(0xFF6FE08D),
    const Color(0xFF618DFD),
    const Color(0xFFFC7F7F),
    const Color(0xFFFFD966),
    const Color(0xFFCB84FB),
    const Color(0xFF78E667),
  ];

  List<Icon> catIcon = [
    const Icon(Icons.car_repair, color: Colors.white, size: 50),
    const Icon(Icons.car_rental, color: Colors.white, size: 50),
    const Icon(Icons.assignment, color: Colors.white, size: 50),
    const Icon(Icons.camera, color: Colors.white, size: 50),
    const Icon(Icons.list, color: Colors.white, size: 50),
    const Icon(Icons.person, color: Colors.white, size: 50),
    const Icon(Icons.logout, color: Colors.white, size: 50),
  ];

  @override
  void initState() {
    super.initState();
    startCheckTimer();
  }

  void startCheckTimer() {
    checkTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
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
          final endTime = DateTime.parse(parkingData['end_time']).toLocal();
          final now = DateTime.now().toLocal();
          final remainingTime = (endTime.difference(now).inSeconds) - 28800;

          carParkingId = parkingData['_id'];

          remainingDurationNotifier.value = remainingTime > 0 ? remainingTime : null; // Update only when valid

          if (remainingTime <= 600 && !tenMinuteWarningSent) {
            print("10 minutes warning sent.");
            tenMinuteWarningSent = true; // Prevent duplicate warnings
          }

          if (remainingTime <= 0) {
            await _terminateTimer(carParkingId!);
            print("Time's up. Parking session terminated.");
          }
        } else {
          carParkingId = null;
          remainingDurationNotifier.value = null;
        }
      }
    } catch (error) {
      print('Error checking parking time: $error');
    }
  }

  Future<void> _terminateTimer(String carParkingId) async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      final url = Uri.parse('$baseUrl/car_parking/$carParkingId/terminate');
      final response = await http.patch(url);

      if (response.statusCode == 200) {
        print('Parking terminated automatically');
        remainingDurationNotifier.value = null; // Reset remaining time
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
    remainingDurationNotifier.dispose(); // Clean up ValueNotifier
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> catLink = [
      CarParkingScreen(userId: widget.userId),
      CarListScreen(userId: widget.userId),
      TransactionScreen(userId: widget.userId),
      SamanScreen(userId: widget.userId),
      // CarScanner(),
      SamanListScreen(userId: widget.userId),
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
                  padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
                  child: Column(
                    children: [
                      GridView.builder(
                        itemCount: catNames.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    builder: (context) => const LoginScreen(),
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
                                    margin: const EdgeInsets.only(bottom: 10, top: 10),
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
                                const SizedBox(height: 10),
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

          // Render TimerControlWidget based on ValueNotifier
          ValueListenableBuilder<int?>(
            valueListenable: remainingDurationNotifier,
            builder: (context, remainingTime, child) {
              if (remainingTime == null || remainingTime <= 0) return const SizedBox.shrink();
              return TimerControlWidget(
                initialTimeInSeconds: remainingTime,
                onExtend: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarParkingUpdateScreen(
                        userId: widget.userId,
                        carParkingId: carParkingId!,
                      ),
                    ),
                  );
                },
                onTerminate: () async {
                  final shouldTerminate = await showConfirmationDialog(
                    context,
                    title: 'Terminate Car Parking',
                    message: 'Are you sure you want to terminate the parking session?',
                    button2Text: "Terminate",
                  );

                  if (shouldTerminate) {
                    await _terminateTimer(carParkingId!);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
