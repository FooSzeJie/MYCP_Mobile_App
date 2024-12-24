import 'package:client/screens/Car/Car_Edit/car_edit_screen.dart';
import 'package:client/screens/Car/Car_Register/car_register_screen.dart';
import 'package:client/screens/Car/components/car.dart';
import 'package:client/components/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class CarList extends StatefulWidget {
  final String userId;  // Pass the user ID when navigating to HomePage

  const CarList({Key? key, required this.userId}) : super(key: key);  // Constructor with userId

  @override
  State<CarList> createState() => _CarListState();
}

class _CarListState extends State<CarList> {
  List<Car> cars = []; // List to hold the cars
  bool isLoading = true; // Loading indicator
  String errorMessage = ''; // For displaying any error that occurs

  @override
  void initState() {
    super.initState();
    _fetchCarList(); // Fetch the cars when the widget is initialized
  }

  Future<void> _fetchCarList() async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      // Correct the URL to match your backend route
      final url = Uri.parse('$baseUrl/vehicles/user/${widget.userId}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('vehicles')) {
          setState(() {
            // Map the vehicles data into the Car model, using null-aware operators
            cars = List<Car>.from(
                data['vehicles'].map((car) =>
                    Car(
                      id: car['_id'].toString() ?? '',
                      licensePlate: car['license_plate'] ?? 'Unknown',
                      // Fallback to 'Unknown' if null
                      color: car['color'] ?? 'Not specified',
                      // Fallback to 'Not specified'
                      brand: car['brand'] ?? 'Unknown', // Fallback to 'Unknown'
                    ))
            );
            isLoading = false;
          });
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
        errorMessage =
        'Error occurred: $error'; // Set the error message for display
      });
    }
  }

  Future<void> _deleteCar(String carId) async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      // Correct the URL to match your backend route
      final url = Uri.parse('$baseUrl/vehicles/${widget.userId}/$carId/delete');

      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          // Remove the car from the list after successful deletion
          cars.removeWhere((car) => car.id == carId);
        });
      } else {
        throw Exception('Failed to delete car: ${response.body}');
      }
    } catch (error) {
      print('Error occurred while deleting: $error');
      setState(() {
        errorMessage = 'Error occurred: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _AddButton(),
            ],
          ),
          const SizedBox(height: 20),

          // Show loading indicator while fetching data
          isLoading
              ? const CircularProgressIndicator()
              : cars.isEmpty && errorMessage.isEmpty
              ? const Text(
            'No Cars yet...',
            style: TextStyle(fontSize: 22),
          )
              : errorMessage.isNotEmpty
              ? Text(
            errorMessage,
            style: const TextStyle(fontSize: 18, color: Colors.red),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) => getRow(index),
            ),
          ),
        ],
      ),
    );
  }

  // Button to navigate to the Car registration form
  Widget _AddButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onPressed: () async {
          // Await the returned Car object from the form
          final Car? newCar = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CarRegisterScreen(userId: widget.userId)),
          );

          // Add the new car to the list if not null
          if (newCar != null) {
            setState(() {
              cars.add(newCar);
            });
          }
        },
        icon: const Icon(
          Icons.add,
          color: Colors.blue,
          size: 30,
        ),
        label: const Text(
          'Add',
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ),
    );
  }

  // Display each car in the list
  Widget getRow(int index) {
    final car = cars[index];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Leading icon for the car (can be modified as per your theme)
            const Icon(
              Icons.directions_car,
              size: 40,
              color: Colors.blue,
            ),
            const SizedBox(width: 12),

            // Car details in a column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'License Plate: ${car.licensePlate}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                          Icons.color_lens, color: Colors.grey, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        'Color: ${car.color}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.branding_watermark,
                          color: Colors.grey, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        'Brand: ${car.brand}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Edit Button
            InkWell(
              onTap: () async {
                // Pass the specific car details to the CarEditScreen
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CarEditScreen(
                          userId: widget.userId, // Pass userId
                          car: car, // Pass the specific car object
                        ),
                  ),
                );
              },
              child: const Icon(
                Icons.edit,
                size: 30,
                color: Colors.blueAccent,
              ),
            ),

            const SizedBox(width: 12,),

            InkWell(
              onTap: () async {
                // Show confirmation dialog before deleting
                final shouldDelete = await showConfirmationDialog(
                  context,
                  title: 'Delete Car',
                  message: 'Are you sure you want to delete this car?'
                );
                if (shouldDelete) {
                  _deleteCar(car.id); // Call delete function
                }
              },
              child: const Icon(
                Icons.delete,
                size: 30,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
