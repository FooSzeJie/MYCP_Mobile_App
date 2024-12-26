import 'package:flutter/material.dart';
import 'package:client/screens/Home%20Page/home_screen.dart';
import 'package:client/components/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding JSON responses

class CreateCarParkingForm extends StatefulWidget {
  final String userId; // Pass the user ID when navigating to HomePage

  const CreateCarParkingForm({Key? key, required this.userId}) : super(key: key);

  @override
  State<CreateCarParkingForm> createState() => _CreateCarParkingFormState();
}

class _CreateCarParkingFormState extends State<CreateCarParkingForm> {
  int _activeStepIndex = 0;
  String _selectedTimeOption = ''; // Holds 'daily' or 'hourly'
  String _selectedCarPlate = '';
  String _selectedCarPlateId = ''; // To store the selected vehicle ID
  String _selectedLocalAuthority = ''; // Stores the selected local authority
  int _selectedDuration = 0; // Duration in minutes
  double _totalPrice = 0.0;
  bool isLoading = true;
  String errorMessage = '';

  // List<String> _carPlates = []; // Updated to fetch from the server
  List<Map<String, String>> _vehicles = [];
  List<Map<String, String>> _localAuthorities = []; // List of local authorities

  final Map<String, int> _hourlyDurations = {
    '30 minutes': 30,
    '1 hour': 60,
    '2 hours': 120,
    '4 hours': 240,
    '8 hours': 480,
    '12 hours': 720,
  };
  final Map<String, int> _dailyDurations = {
    '1 day': 1440,
    '2 days': 2880,
    '5 days': 7200,
    '7 days': 10080,
    '14 days': 20160,
  };
  final Map<int, double> _hourlyPrices = {
    30: 0.4,
    60: 0.6,
    120: 1.2,
    240: 2.4,
    480: 4.8,
    720: 7.2,
  };
  final Map<int, double> _dailyPrices = {
    1440: 10.0,
    2880: 20.0,
    7200: 50.0,
    10080: 70.0,
    20160: 140.0,
  };

  final List<Map<String, String>> _steps = [
    {
      'label': 'Select Option',
      'description': 'Choose whether the campaign should be managed on a daily or hourly basis.',
    },
    {
      'label': 'Car and Duration',
      'description': 'Select the car plate and the duration (hourly or daily) based on your previous choice.',
    },
    {
      'label': 'Review and Confirm',
      'description': 'Review all selections and confirm your choices before proceeding.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchVehicleByUser();
    _fetchDefaultVehicle();
    _fetchLocalAuthority(); // Fetch local authorities on initialization
  }

  Future<void> _fetchVehicleByUser() async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final url = Uri.parse('$baseUrl/vehicles/user/${widget.userId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('vehicles')) {
          setState(() {
            _vehicles = List<Map<String, String>>.from(
              data['vehicles'].map(
                    (car) => {
                  'id': car['_id'].toString(),
                  'license_plate': car['license_plate'].toString(),
                },
              ),
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
        errorMessage = 'Error occurred: $error';
      });
    }
  }

  void _onStepContinue() {
    if (_activeStepIndex < _steps.length - 1) {
      setState(() {
        _activeStepIndex++;
      });
    } else if (_activeStepIndex == _steps.length - 1) {
      _handleCreateCarParking();
    }
  }

  void _onStepCancel() {
    if (_activeStepIndex > 0) {
      setState(() {
        _activeStepIndex--;
      });
    }
  }

  void _onStepReset() {
    setState(() {
      _activeStepIndex = 0;
      _selectedTimeOption = '';
      _selectedCarPlate = '';
      _selectedDuration = 0;
      _totalPrice = 0.0;
    });
  }

  bool _isStepComplete(int index) {
    if (index == 0) {
      return _selectedTimeOption.isNotEmpty;
    } else if (index == 1) {
      return _selectedCarPlate.isNotEmpty && _selectedDuration > 0;
    }
    return true;
  }

  void _updateTotalPrice() {
    if (_selectedTimeOption == 'hourly') {
      _totalPrice = _hourlyPrices[_selectedDuration] ?? 0.0;
    } else if (_selectedTimeOption == 'daily') {
      _totalPrice = _dailyPrices[_selectedDuration] ?? 0.0;
    }
  }

  Future<void> _fetchDefaultVehicle() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final baseUrl = dotenv.env["FLUTTER_APP_BACKEND_URL"];
      final url = Uri.parse('$baseUrl/users/${widget.userId}/default_vehicle');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['user']['default_vehicle'] != null) {
          final defaultVehicleId = data['user']['default_vehicle']['_id'];
          final defaultVehicle = _vehicles.firstWhere(
                (v) => v['id'] == defaultVehicleId,
            orElse: () => {},
          );

          setState(() {
            _selectedCarPlate = defaultVehicle['license_plate'] ?? '';
            _selectedCarPlateId = defaultVehicle['id'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error occurred: $e';
      });
    }
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

  Future<void> _handleCreateCarParking() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final starting_time = DateTime.now().toUtc();
    final duration = _selectedDuration;
    final local_authority = _selectedLocalAuthority;
    final vehicle = _selectedCarPlateId;

    final payload = {
      'starting_time': starting_time.toIso8601String(),
      'duration': duration,
      'local_authority': local_authority,
      'vehicle': vehicle,
      'creator': widget.userId,
      'price': _totalPrice,
    };

    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/car_parking/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        await _handleCreateParkingTransaction();

        await _sendEmail();

        // Await the dialog box to ensure it is displayed before navigation
        await showDialogBox(
          context,
          title: 'Success',
          message: 'Car parking successfully created.',
        );

        // Navigate to the home page after the dialog is closed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)),
        );
      } else {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? 'Creation failed. Please try again.';

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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleCreateParkingTransaction() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    // Find the nickname based on the selected local authority ID
    final localAuthority = _localAuthorities.firstWhere(
          (authority) => authority['id'] == _selectedLocalAuthority,
      orElse: () => {'name': _selectedLocalAuthority}, // Fallback to ID if not found
    );

    final localAuthorityName = localAuthority['name'] ?? _selectedLocalAuthority;

    final payload = {
      "name" : "Paid Car Parking Fees",
      "money" :  _totalPrice,
      'deliver': localAuthorityName,
      'creator': widget.userId,
    };

    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/transaction/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? 'Creation failed. Please try again.';

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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendEmail() async {
    final payload = {
      'subject': "MYCP Paid Parking Fees",
      'message': "You are already Paid RM${_totalPrice.toStringAsFixed(2)} for Parking Fee in the MyCP APP"
    };

    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      final response = await http.post(
        Uri.parse('$baseUrl/users/${widget.userId}/send_email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        print("Email error: $errorData");
      }
    } catch (e) {
      print('Error occurred while sending Email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _activeStepIndex,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              steps: _steps.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> step = entry.value;

                return Step(
                  title: Text(
                    step['label']!,
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  content: _buildStepContent(index, step),
                  isActive: _activeStepIndex >= index,
                  state: _activeStepIndex > index ? StepState.complete : StepState.indexed,
                );
              }).toList(),
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                bool canContinue = _isStepComplete(_activeStepIndex);
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: canContinue ? details.onStepContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canContinue ? Theme.of(context).primaryColor : Colors.grey,
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        textStyle: TextStyle(fontSize: 16.0),
                      ),
                      child: Text(_activeStepIndex == _steps.length - 1 ? 'Finish' : 'Continue'),
                    ),

                    SizedBox(width: 8),

                    if (_activeStepIndex > 0)

                      ElevatedButton(
                        onPressed: details.onStepCancel,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                          textStyle: TextStyle(fontSize: 16.0),
                        ),
                        child: Text('Back'),
                      ),
                  ],
                );
              },
            ),
          ),
          if (_activeStepIndex == _steps.length)
            FloatingActionButton.extended(
              onPressed: _onStepReset,
              label: Text('Reset', style: TextStyle(fontSize: 16.0)),
              icon: Icon(Icons.restart_alt),
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int index, Map<String, String> step) {
    switch (index) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(step['description']!, style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 8),
            Row(
              children: [
                _optionButton('Hourly'),
                SizedBox(width: 8),
                _optionButton('Daily'),
              ],
            ),
            SizedBox(height: 25),
          ],
        );
      case 1:
        return isLoading
            ? CircularProgressIndicator() // Show loader if data is still being fetched
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(step['description']!, style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 8),

            _localAuthorityDropdown(),

            SizedBox(height: 10,),

            _carPlateDropdown(),

            SizedBox(height: 16),

            _durationButtons(),
            SizedBox(height: 30),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(step['description']!, style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 8),
            _reviewSelections(),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  ElevatedButton _optionButton(String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTimeOption = label.toLowerCase();
          _selectedDuration = 0; // Reset duration when changing option
          _totalPrice = 0.0; // Reset price when changing option
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedTimeOption == label.toLowerCase() ? Colors.blue : Colors.grey,
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        textStyle: TextStyle(fontSize: 16.0),
      ),
      child: Text(label),
    );
  }

  DropdownButton<String> _carPlateDropdown() {
    if (_selectedCarPlate.isEmpty && _vehicles.isNotEmpty) {
      // Automatically select the default vehicle if available
      final defaultVehicle = _vehicles.firstWhere(
            (vehicle) => vehicle['id'] == widget.userId, // Assuming `userId` is tied to the default vehicle
        orElse: () => _vehicles.first, // Fallback to the first vehicle
      );

      _selectedCarPlate = defaultVehicle['license_plate'] ?? '';
      _selectedCarPlateId = defaultVehicle['id'] ?? '';
    }

    return DropdownButton<String>(
      value: _selectedCarPlate.isEmpty ? null : _selectedCarPlate,
      hint: const Text('Select car plate', style: TextStyle(fontSize: 16.0)),
      items: _vehicles.map((vehicle) {
        return DropdownMenuItem(
          value: vehicle['license_plate'],
          child: Text(vehicle['license_plate'] ?? '', style: const TextStyle(fontSize: 16.0)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCarPlate = value ?? '';
          _selectedCarPlateId = _vehicles.firstWhere((v) => v['license_plate'] == value)['id']!;
        });
      },
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

  Widget _durationButtons() {
    return Wrap(
      spacing: 8,
      children: (_selectedTimeOption == 'daily' ? _dailyDurations.keys : _hourlyDurations.keys).map((duration) {
        return ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedDuration = _selectedTimeOption == 'daily'
                  ? _dailyDurations[duration]!
                  : _hourlyDurations[duration]!;
              _updateTotalPrice();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedDuration == (_selectedTimeOption == 'daily' ? _dailyDurations[duration] : _hourlyDurations[duration]) ? Colors.blue : Colors.grey,
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            textStyle: TextStyle(fontSize: 16.0),
          ),
          child: Text(duration),
        );
      }).toList(),
    );
  }

  Widget _reviewSelections() {
    return Column(
      children: [
        _buildReviewText('Time Option', _selectedTimeOption.isEmpty ? 'Not selected' : _selectedTimeOption),
        _buildReviewText('Selected Car Plate', _selectedCarPlate.isEmpty ? 'Not selected' : _selectedCarPlate),
        _buildReviewText('Duration', _selectedDuration == 0 ? 'Not selected' : '$_selectedDuration minutes'),
        SizedBox(height: 20),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16.0),
            children: [
              TextSpan(text: 'Price: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: 'RM ${_totalPrice.toStringAsFixed(2)}'), // Ensure price is formatted to 2 decimal places
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  RichText _buildReviewText(String title, String value) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16.0),
        children: [
          TextSpan(text: '$title: ', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
