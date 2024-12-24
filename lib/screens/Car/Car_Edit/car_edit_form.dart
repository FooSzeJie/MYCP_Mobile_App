import 'package:client/screens/Car/Car_List/car_list_screen.dart';
import 'package:client/screens/Car/components/car.dart';
import 'package:client/components/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class CarEditForm extends StatefulWidget {
  final String userId; // Pass the user ID when navigating to HomePage
  final Car car; // Pass the Car object

  const CarEditForm({Key? key, required this.userId, required this.car})
      : super(key: key);

  @override
  State<CarEditForm> createState() => _CarEditForm();
}

class _CarEditForm extends State<CarEditForm> {
  // Text Controller
  TextEditingController licensePlateController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  String? _defaultVehicle; // Stores the default vehicle's license plate

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

  bool isLoading = false;
  bool isDefault = false;

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with the current car details
    licensePlateController.text = widget.car.licensePlate;
    colorController.text = widget.car.color;
    brandController.text = widget.car.brand;
    selectedColor = widget.car.color;
    selectedBrand = widget.car.brand;

    _fetchDefaultVehicle();
  }

  Future<void> _fetchDefaultVehicle() async {
    setState(() {
      isLoading = true;
    });

    try {
      final baseUrl = dotenv.env["FLUTTER_APP_BACKEND_URL"];
      final url = Uri.parse('$baseUrl/users/${widget.userId}/default_vehicle');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['user']['default_vehicle'] != null) {
          // Correctly fetch the default_vehicle license_plate
          setState(() {
            _defaultVehicle = data['user']['default_vehicle']['license_plate'] ?? '';
            isDefault = _defaultVehicle == licensePlateController.text;
          });
        }
      } else {
        throw Exception('Failed to fetch default vehicle.');
      }
    } catch (e) {
      print('Error fetching default vehicle: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _handleUpdateCar() async {
    setState(() {
      isLoading = true;
    });

    final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

    try {
      final url = Uri.parse('$baseUrl/vehicles/${widget.car.id}/update');

      final payload = {
        'license_plate': licensePlateController.text,
        'color': colorController.text,
        'brand': brandController.text,
        'creator': widget.userId,
        'default_vehicle': isDefault,
      };

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        await showDialogBox(
          context,
          title: 'Updated Successfully',
          message: "You have successfully updated the car information.",
        );

        // Navigate back to the car list
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CarListScreen(userId: widget.userId),
          ),
        );
      } else {
        throw Exception('Failed to update the car.');
      }
    } catch (e) {
      print('Error updating car: $e');
      await showDialogBox(
        context,
        title: 'Update Failed',
        message: "Failed to update car details. Please try again.",
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Form(
          child: Column(
            children: [
              TextField(
                controller: licensePlateController,
                maxLength: 8,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: "License Plate Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                inputFormatters: [UpperCaseTextFormatter()],
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),

              CheckboxListTile(
                value: isDefault,
                title: const Text(
                  "Set as Default Vehicle",
                  style: TextStyle(fontSize: 20),
                ),
                onChanged: (value) => setState(() => isDefault = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleUpdateCar,
                    child: const Text("Update"),
                  ),
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
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: DropdownButton<String>(
            value: value,
            iconSize: 36,
            icon: const Icon(
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
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
  );
}

// Formatter for Uppercase Conversion
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase().replaceAll(' ', ''),
      selection: newValue.selection,
    );
  }
}
