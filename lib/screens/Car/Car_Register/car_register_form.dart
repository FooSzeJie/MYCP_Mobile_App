import 'package:client/screens/Car/components/car.dart';
import 'package:flutter/material.dart';

class CarRegisterForm extends StatefulWidget {
  final String userId;  // Pass the user ID when navigating to HomePage

  const CarRegisterForm({Key? key, required this.userId}) : super(key: key);  // Constructor with userId

  @override
  State<CarRegisterForm> createState() => _CarRegisterFormState();
}

class _CarRegisterFormState extends State<CarRegisterForm> {
  // Text Controller
  TextEditingController licensePlateController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController brandController = TextEditingController();

  final colors = [
    'White',
    'Black',
    'Red',
    'Orange',
    'Yellow',
    'Green',
    'Blue',
    'Purple',
    'Silver'
  ];
  String? selectedColor;

  final brands = [
    'Perodua',
    'Toyota',
    'Honda',
    'Mitsubishi',
    'Mercedes-Benz',
    'BMW',
    'Audi',
    'Proton',
    'Tesla'
  ];
  String? selectedBrand;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                TextField(
                  controller: licensePlateController,
                  maxLength: 8,
                  decoration: InputDecoration(
                    hintText: "License Plate Number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                _buildDropdownField(
                  title: 'Car Color:',
                  value: selectedColor,
                  items: colors,
                  onChanged: (value) {
                    setState(() {
                      selectedColor = value;
                      colorController.text = value!;
                    });
                  },
                ),
                SizedBox(height: 10),
                _buildDropdownField(
                  title: 'Car Brand:',
                  value: selectedBrand,
                  items: brands,
                  onChanged: (value) {
                    setState(() {
                      selectedBrand = value;
                      brandController.text = value!;
                    });
                  },
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _saveCar(context);
                        },
                        child: Text("Save")),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  }

  // Save the car and return to the previous screen
  void _saveCar(BuildContext context) {
    String licensePlate = licensePlateController.text.trim();
    String color = colorController.text.trim();
    String brand = brandController.text.trim();

    if (licensePlate.isEmpty || color.isEmpty || brand.isEmpty) {
      _showErrorDialog(context, "All fields must be filled.");
      return;
    }

    final newCar = Car(
      licensePlate: licensePlate,
      color: color,
      brand: brand,
    );

    Navigator.pop(context, newCar); // Return the new car
  }

  Widget _buildDropdownField({
    required String title,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)),
        ),
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: DropdownButton<String>(
            value: value,
            iconSize: 36,
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ),
            items: items.map(buildMenuItem).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
  );

  Future<void> _showErrorDialog(BuildContext context, String errorMessage) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
