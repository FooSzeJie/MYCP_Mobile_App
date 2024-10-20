import 'package:client/screens/Car/Car_Register/car_register_screen.dart';
import 'package:client/screens/Car/components/car.dart';
import 'package:flutter/material.dart';

class CarList extends StatefulWidget {
  const CarList({super.key});

  @override
  State<CarList> createState() => _CarListState();
}

class _CarListState extends State<CarList> {
  List<Car> cars = List.empty(growable: true); // List to hold the cars

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
          cars.isEmpty
              ? const Text(
            'No Cars yet...',
            style: TextStyle(fontSize: 22),
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
            MaterialPageRoute(builder: (context) => CarRegisterScreen()),
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
                      const Icon(Icons.color_lens, color: Colors.grey, size: 20),
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
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
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
