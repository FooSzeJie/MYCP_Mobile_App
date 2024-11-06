import 'package:client/screens/Car%20Parking/components/car_parking_update_form.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:client/components/dialog.dart';
import 'package:client/screens/Car%20Parking/car_parking_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CarParkingStatus extends StatefulWidget {
  final String userId;

  const CarParkingStatus({Key? key, required this.userId}) : super(key: key);

  @override
  State<CarParkingStatus> createState() => _CarParkingStatusState();
}

class _CarParkingStatusState extends State<CarParkingStatus> {
  int countdownTime = 0; // Countdown time in seconds
  Timer? timer;
  bool isLoading = true;
  String errorMessage = '';
  String? carParkingId; // Store the car parking ID for termination

  @override
  void initState() {
    super.initState();
    _fetchTimer();
  }

  Future<void> _fetchTimer() async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final url = Uri.parse('$baseUrl/car_parking/${widget.userId}/status');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('carParking') && data['carParking'].isNotEmpty) {
          final parkingData = data['carParking'][0];

          // Store carParkingId for later use in termination
          carParkingId = parkingData['_id']; // Ensure _id is available

          if (parkingData.containsKey('end_time')) {
            // Parse the ISO 8601 end time
            final endTime = DateTime.parse(parkingData['end_time']).toUtc();
            final now = DateTime.now().toUtc();
            final remainingDuration = endTime.difference(now).inSeconds;

            setState(() {
              countdownTime = remainingDuration > 0 ? remainingDuration : 0;
              isLoading = false;
            });

            // Start the countdown
            startTimer();
          } else {
            setState(() {
              isLoading = false;
              errorMessage = 'End timer not found for ongoing parking.';
            });
          }
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'No vehicles found for the user.';
          });
        }
      } else {
        throw Exception('Failed to load car information: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
      setState(() {
        isLoading = false;
        errorMessage = 'Error occurred: $error';
      });
    }
  }

  Future<void> _terminateTimer(String carParkingId) async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final url = Uri.parse('$baseUrl/car_parking/$carParkingId/terminate');
      final response = await http.patch(url);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CarParkingScreen(userId: widget.userId)),
        );
      } else {
        throw Exception('Failed to terminate parking: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
      setState(() {
        errorMessage = 'Error occurred: $error';
      });
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (countdownTime > 0) {
        setState(() {
          countdownTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void extendTimer() {
    if (carParkingId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CarParkingUpdate(userId: widget.userId, carParkingId: carParkingId!)), // Use '!' to assert non-null
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to extend parking: Parking ID is not available.')),
      );
    }
  }

  void stopTimer() {
    if (carParkingId != null) {
      _terminateTimer(carParkingId!);
    } else {
      setState(() {
        errorMessage = 'Parking ID not found for termination.';
      });
    }
  }

  String formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : errorMessage.isNotEmpty
            ? Text(errorMessage)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Car Parking Timer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                formatTime(countdownTime),
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: extendTimer,
                    child: Text(
                      'Extend',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: stopTimer,
                    child: Text(
                      'Stop',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}