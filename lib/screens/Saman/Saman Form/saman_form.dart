import 'package:client/components/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SamanForm extends StatefulWidget {
  final String userId;

  const SamanForm({Key? key, required this.userId}) : super(key: key);

  @override
  State<SamanForm> createState() => _SamanFormState();
}

class _SamanFormState extends State<SamanForm> {
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
  String errorMessage = '';

  Future<void> _checkCarDuration() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final licensePlate = licensePlateController.text.trim();
    final color = selectedColor ?? '';
    final brand = selectedBrand ?? '';

    if (licensePlate.isEmpty || color.isEmpty || brand.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    final payload = {
      'license_plate': licensePlate,
      'color': color,
      'brand': brand,
    };

    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/car_parking/check_status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 404) {
        // If no ongoing parking, create saman
        await _givenSaman(licensePlate);

        showDialogBox(
          context,
          title: 'Given Saman',
          message: 'The car has not paid the parking fee.',
        );
      } else if (response.statusCode == 200) {
        showDialogBox(
          context,
          title: 'Success',
          message: 'The car has paid the parking fee.',
        );
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          errorMessage = errorData['message'] ?? 'Error occurred. Please try again.';
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _givenSaman(String licensePlate) async {
    final payload = {
      "name": "Parking Fee Not Paid",
      'date': DateTime.now().toIso8601String(),
      'license_plate': licensePlate,
      'creator': widget.userId,
    };

    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/saman/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        setState(() {
          errorMessage = errorData['message'] ?? 'Failed to issue saman.';
        });

        showDialogBox(
          context,
          title: 'Error',
          message: errorMessage,
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      showDialogBox(
        context,
        title: 'Error',
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }


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
                        _checkCarDuration();
                      },
                      child: Text("Check")),
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
