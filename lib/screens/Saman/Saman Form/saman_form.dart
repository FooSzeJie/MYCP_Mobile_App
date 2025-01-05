import 'package:client/components/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  List<Map<String, String>> _localAuthorities = []; // List of local authorities
  String _selectedLocalAuthority = ''; // Stores the selected local authority

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
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLocalAuthority(); // Fetch local authorities on initialization
  }

  Future<void> _fetchLocalAuthority() async {
    try {
      final baseUrl = dotenv.env["FLUTTER_APP_BACKEND_URL"];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }
      final url = Uri.parse('$baseUrl/local_authority/list');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('localAuthority')) {
          setState(() {
            _localAuthorities = List<Map<String, String>>.from(
              data['localAuthority'].map(
                    (authority) => {
                  'id': authority['_id'].toString(),
                  'name': authority['nickname'].toString(),
                },
              ),
            );
            // Set the default selected local authority
            _selectedLocalAuthority = _localAuthorities.isNotEmpty
                ? _localAuthorities[0]['id']!
                : '';
          });
        } else {
          throw Exception('No local authorities found.');
        }
      } else {
        throw Exception('Failed to fetch local authorities: ${response.body}');
      }
    } catch (e) {
      print('Error fetching local authorities: $e');
      setState(() {
        errorMessage = 'Error fetching local authorities: $e';
      });
    }
  }

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
      showDialogBox(
        context,
        title: 'Error',
        message: 'Please fill in all fields.',
      );

      return;
    }

    final payload = {
      'license_plate': licensePlate,
      'color': color,
      'brand': brand,
      'local_authority': _selectedLocalAuthority,
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
        // Vehicle not found
        showDialogBox(
          context,
          title: 'Error',
          message: 'The vehicle details do not match any records.',
        );

      } else if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('message') && data['message'] == 'No ongoing car parking found') {
          // Vehicle found but no ongoing parking
          await _givenSaman(licensePlate);
        } else {
          // Ongoing parking exists
          showDialogBox(
            context,
            title: 'Success',
            message: 'The car has already paid for parking.',
          );
        }
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
    setState(() {
      isLoading = true;
    });

    final payload = {
      "offense": "Parking Fee Not Paid",
      'license_plate': licensePlate,
      'creator': widget.userId,
      "local_authority" : _selectedLocalAuthority,
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

      if (response.statusCode == 201) {
        showDialogBox(
          context,
          title: 'Given Saman',
          message: 'The car has not paid the parking fee.',
        );
      }
      else {
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
    finally {
      isLoading = false;
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

              _localAuthorityDropdown(),

              SizedBox(height: 10,),

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

  DropdownButton<String> _localAuthorityDropdown() {
    return DropdownButton<String>(
      value: _selectedLocalAuthority.isEmpty ? null : _selectedLocalAuthority,
      hint: const Text('Select Local Authority', style: TextStyle(fontSize: 16.0)),
      items: _localAuthorities.map((authority) {
        return DropdownMenuItem(
          value: authority['id'],
          child: Text(authority['name'] ?? '', style: const TextStyle(fontSize: 16.0)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLocalAuthority = value ?? '';
        });
      },
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