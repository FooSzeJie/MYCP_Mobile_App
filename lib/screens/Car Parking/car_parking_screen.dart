import 'package:client/screens/Car%20Parking/components/car_parking_form.dart';
import 'package:client/screens/Car%20Parking/Create%20Car%20Parking/create_car_parking_form.dart';
import 'package:client/screens/Car Parking/components/car_parking_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding JSON responses

class CarParkingScreen extends StatefulWidget {
  final String userId;  // Pass the user ID when navigating to HomePage

  const CarParkingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CarParkingScreen> createState() => _CarParkingScreenState();
}

class _CarParkingScreenState extends State<CarParkingScreen> {
  bool isLoading = true;
  String? errorMessage;
  String? parkingStatus; // Variable to hold the parking status

  @override
  void initState() {
    super.initState();
    _fetchCarParkingByUser();
  }

  Future<void> _fetchCarParkingByUser() async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final url = Uri.parse('$baseUrl/car_parking/${widget.userId}/status');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Assume the response has a key 'carParking' that contains a list of parking data
        if (data.containsKey('carParking') && data['carParking'].isNotEmpty) {
          setState(() {
            parkingStatus = data['carParking'][0]['status']; // Get status of the first car parking
            isLoading = false;
          });
        }
        else {
          setState(() {
            isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Car Parking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : parkingStatus == "ongoing"
          ? CarParkingStatus(userId: widget.userId,) // Show CarParkingStatus widget
          : CreateCarParkingForm(userId: widget.userId), // Show StepProgressModal widget
    );
  }
}
