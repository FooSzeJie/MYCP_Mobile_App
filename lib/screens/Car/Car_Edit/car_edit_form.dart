import 'package:client/screens/Car/Car_List/car_list_screen.dart';
import 'package:client/screens/Car/components/car.dart';
import 'package:client/components/input_field.dart';
import 'package:client/components/dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class CarEditForm extends StatefulWidget {
  final String userId;  // Pass the user ID when navigating to HomePage
  final Car car;  // Pass the Car object

  const CarEditForm({Key? key, required this.userId, required this.car}) : super(key: key);  // Constructor with userId

  @override
  State<CarEditForm> createState() => _CarEditForm();
}

class _CarEditForm extends State<CarEditForm> {
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

  bool isLoading = true;

  @override

  void initState() {
    super.initState();

    // Initialize the text controllers with the current car details
    licensePlateController.text = widget.car.licensePlate;
    colorController.text = widget.car.color;
    brandController.text = widget.car.brand;
    selectedColor = widget.car.color; // Set initial color
    selectedBrand = widget.car.brand; // Set initial brand
  }

  Future <void> _handleUpdateCar () async {
    final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

    try {
      final url = Uri.parse('$baseUrl/vehicles/${widget.car.id}/update');

      Map<String, dynamic> body = {
        'license_plate': licensePlateController.text,
        'color': colorController.text,
        'brand': brandController.text,
      };

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Show the dialog and wait for it to be dismissed
        await showDialogBox(
          context,
          title: 'Updated Successfully',
          message: "You have successfully updated the car information.",
        );

        // After dialog is dismissed, navigate back to the car list
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CarListScreen(userId: widget.userId),
          ),
        );

      } else {
        throw Exception('Failed to update profile');
      }
    } catch (error) {
      print('Error updating profile: $error');

      // Show the Dialog
      showDialogBox(
        context,
        title: 'Updated Failed',       // Optional: Custom title
        message: "Error updating profile. Please try again.",  // Required: Error message
      );
    }
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Form(
          child: Column(
            children: [

              InputField(controller: licensePlateController, hintText: 'License Plate Number', maxlength: 8,),

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
                        _handleUpdateCar();
                      },
                      child: Text("Update")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

}
