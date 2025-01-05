import 'package:client/screens/Car%20Parking/Parking%20History/parking_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:client/screens/Car Parking/components/Parking.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ParkingList extends StatefulWidget {
  final String userId;

  const ParkingList({Key? key, required this.userId}) : super(key: key);

  @override
  State<ParkingList> createState() => _ParkingListState();
}

class _ParkingListState extends State<ParkingList> {
  List<Parking> parkingList = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime? selectedStartDate; // Start date for filtering
  DateTime? selectedEndDate; // End date for filtering

  @override
  void initState() {
    super.initState();
    // Show today's transactions by default
    final today = DateTime.now();
    selectedStartDate = DateTime(today.year, today.month, today.day);
    selectedEndDate = DateTime(today.year, today.month, today.day);
    _fetchParkingList(); // Fetch today's parking history
  }

  Future<void> _fetchParkingList() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final baseUrl = dotenv.env["FLUTTER_APP_BACKEND_URL"];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      // Format dates for the API
      final startDateString = selectedStartDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedStartDate!)
          : null;
      final endDateString = selectedEndDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedEndDate!)
          : null;

      // API endpoint with optional date filters
      final url = Uri.parse(
          '$baseUrl/car_parking/${widget.userId}/parking_history?start_date=$startDateString&end_date=$endDateString');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('carParking')) {
          setState(() {
            parkingList = List<Parking>.from(
              data['carParking'].map(
                    (parking) => Parking(
                  id: parking['_id']?.toString() ?? '',
                  start_date: parking['start_time'] ?? 'No Start Time',
                  end_date: parking['end_time'] ?? 'No End Time',
                  duration: parking['duration'] ?? 0,
                  licensePlate: parking['vehicle']?['license_plate'] ?? 'Unknown',
                  deliver: parking['deliver'] ?? 'Unknown',
                ),
              ),
            );
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'No car parking history found for the user.';
          });
        }
      } else {
        throw Exception('Failed to load car parking history: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
      setState(() {
        isLoading = false;
        errorMessage = 'Error occurred: $error';
      });
    }
  }

  void _selectDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedStartDate != null && selectedEndDate != null
          ? DateTimeRange(start: selectedStartDate!, end: selectedEndDate!)
          : null,
    );

    if (pickedRange != null) {
      setState(() {
        selectedStartDate = pickedRange.start;
        selectedEndDate = pickedRange.end;
      });

      // Fetch filtered parking history
      _fetchParkingList();
    }
  }

  Widget _buildParkingTile(Parking parking) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ParkingDetail(
                  license_plate: parking.licensePlate,
                  start_date: parking.start_date,
                  end_date: parking.end_date,
                  duration: parking.duration,
                  deliver: parking.deliver,
                ),
              ),
            );
          },
          child: ListTile(
            leading: Icon(
              Icons.car_rental,
              color: Colors.blue,
              size: 30,
            ),
            title: Text(
              'License Plate: ${parking.licensePlate}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Start: ${parking.start_date}\nEnd: ${parking.end_date}\nDeliver: ${parking.deliver}',
            ),
            trailing: Text(
              '${parking.duration} min',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Parking History (${DateFormat('yyyy-MM-dd').format(selectedStartDate!)} to ${DateFormat('yyyy-MM-dd').format(selectedEndDate!)})",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _selectDateRange,
                child: const Text("Filter"),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : parkingList.isNotEmpty
              ? ListView.builder(
            itemCount: parkingList.length,
            itemBuilder: (context, index) =>
                _buildParkingTile(parkingList[index]),
          )
              : Center(
            child: Text(
              errorMessage.isNotEmpty
                  ? errorMessage
                  : 'No parking history available.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
