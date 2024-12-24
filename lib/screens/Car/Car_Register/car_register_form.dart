import 'package:client/screens/Car/components/car.dart';
import 'package:client/components/dialog.dart';
import 'package:client/screens/Car/Car_List/car_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding JSON responses

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

  bool isDefault = false;
  bool isLoading = true;
  String errorMessage = '';

  Future<void> _handleCreateCar() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final licensePlate = licensePlateController.text.trim();
    final color = colorController.text.trim();
    final brand = brandController.text.trim();

    if (licensePlate.isEmpty || color.isEmpty || brand.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Please fill in all fields.';
      });

      // Show the Dialog
      showDialogBox(
        context,
        title: 'Car Register Fail',       // Optional: Custom title
        message: errorMessage,  // Required: Error message
      );

      return;
    }

    final payload = {
      'license_plate': licensePlate,
      'color': color,
      'brand': brand,
      'creator': widget.userId,
      'default_vehicle': isDefault,
    };

    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      // print('Sending request to: $baseUrl/users/register');

      final response = await http.post(
        Uri.parse('$baseUrl/vehicles/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        setState(() {
          print(data);
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CarListScreen(userId: widget.userId)),
        );

      } else {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? 'Registration failed. Please try again.';

        // Show the Dialog
        showDialogBox(
          context,
          title: 'Car Register Fail 2',       // Optional: Custom title
          message: errorMessage,  // Required: Error message
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      errorMessage = 'An error occurred. Please check your connection and try again.';

      // Show the Dialog
      showDialogBox(
        context,
        title: 'Register Fail',       // Optional: Custom title
        message: errorMessage,  // Required: Error message
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: "License Plate Number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  // Enforce uppercase using TextInputFormatter
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
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

                CheckboxListTile(
                  value: isDefault,
                  title: Text(
                      "Set as Default Vehicle",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  onChanged: (value) => setState(() => isDefault = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _handleCreateCar();
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

// Custom Formatter for Uppercase Conversion
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      // Convert to uppercase and remove spaces
      text: newValue.text.toUpperCase().replaceAll(' ', ''),
      selection: newValue.selection,
    );
  }
}
