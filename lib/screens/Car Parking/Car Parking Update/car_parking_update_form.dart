import 'package:flutter/material.dart';
import 'package:client/screens/Home%20Page/home_screen.dart';
import 'package:client/components/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding JSON responses

class CarParkingUpdateForm extends StatefulWidget {
  final String userId; // Pass the user ID when navigating to HomePage
  final String carParkingId;

  const CarParkingUpdateForm({Key? key, required this.userId, required this.carParkingId}) : super(key: key);

  @override
  State<CarParkingUpdateForm> createState() => _CarParkingUpdateFormState();
}

class _CarParkingUpdateFormState extends State<CarParkingUpdateForm> {
  int _activeStepIndex = 0;
  String _selectedTimeOption = ''; // Holds 'daily' or 'hourly'
  String _selectedCarPlate = '';
  int _selectedDuration = 0; // Duration in minutes
  double _totalPrice = 0.0;
  bool isLoading = true;
  String errorMessage = '';

  List<String> _carPlates = []; // Updated to fetch from the server
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
  }

  Future<void> _fetchVehicleByUser() async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final url = Uri.parse('$baseUrl/car_parking/${widget.userId}/status');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('carParking') && data['carParking'].isNotEmpty) {
          final parkingData = data['carParking'][0];

          setState(() {
            _selectedCarPlate = parkingData['vehicle']['license_plate'];
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

  Future<void> _updateCarParking() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final duration = _selectedDuration;

    final payload = {
      'duration': duration,
      "price" : _totalPrice,
    };

    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/car_parking/${widget.carParkingId}/extend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {

        await _handleCreateParkingTransaction();

        showDialogBox(
          context,
          title: 'Success',
          message: 'Car parking successfully created.',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)),
        );

      } else {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? 'Extends failed. Please try again.';

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

    final local_authority = "MBJB";

    final payload = {
      "name" : "Extend the Parking Duration",
      "money" :  _totalPrice,
      'deliver': local_authority,
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

  void _onStepContinue() {
    if (_activeStepIndex < _steps.length - 1) {
      setState(() {
        _activeStepIndex++;
      });
    } else if (_activeStepIndex == _steps.length - 1) {
      _updateCarParking();
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

            Text('Car Plate: $_selectedCarPlate', style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            ),

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
    return DropdownButton<String>(
      value: _selectedCarPlate.isEmpty ? null : _selectedCarPlate,
      hint: Text('Select car plate', style: TextStyle(fontSize: 16.0)),
      items: _carPlates.map((plate) {
        return DropdownMenuItem(
          value: plate,
          child: Text(plate, style: TextStyle(fontSize: 16.0)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCarPlate = value ?? '';
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
        _buildReviewText('Extend', _selectedDuration == 0 ? 'Not selected' : '$_selectedDuration minutes'),
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