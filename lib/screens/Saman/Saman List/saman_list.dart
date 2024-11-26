import 'package:client/screens/Saman/Saman%20List/Saman%20List%20Detail.dart';
import 'package:client/screens/Saman/Saman%20List/saman_list_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SamanList extends StatefulWidget {
  final String userId;

  const SamanList({Key? key, required this.userId}) : super(key: key);

  @override
  State<SamanList> createState() => _SamanListState();
}

class _SamanListState extends State<SamanList> {
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> vehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchSamanHistory();
  }

  Future<void> _fetchSamanHistory() async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set in the .env file.');
      }

      final url = Uri.parse('$baseUrl/saman/${widget.userId}/list');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          vehicles = List<Map<String, dynamic>>.from(data['vehicles']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch saman history: ${response.body}';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
        isLoading = false;
      });
    }
  }

  Widget _buildSamanCard(Map<String, dynamic> saman) {
    final isPaid = saman['status'] == 'paid';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SamanListDetailScreen(userId: widget.userId, saman: saman),
            ),
          );
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isPaid ? Colors.green : Colors.red,
            child: Icon(
              isPaid ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
          ),
          title: Text(
            'Offense: ${saman['offense'] ?? 'Unknown'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Date: ${saman['date'] ?? 'Unknown'}\nAmount: RM${saman['price']?.toStringAsFixed(2) ?? '0.00'}',
          ),
          trailing: Text(
            saman['status']?.toUpperCase() ?? 'UNKNOWN',
            style: TextStyle(
              color: isPaid ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    final samanHistory = List<Map<String, dynamic>>.from(vehicle['saman_history'] ?? []);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ExpansionTile(
        title: Text(
          vehicle['license_plate'] ?? 'Unknown License Plate',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Brand: ${vehicle['brand'] ?? 'Unknown'}, Color: ${vehicle['color'] ?? 'Unknown'}',
        ),
        children: samanHistory.isNotEmpty
            ? samanHistory.map((saman) => _buildSamanCard(saman)).toList()
            : [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No saman history available for this vehicle.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      )
          : vehicles.isEmpty
          ? const Center(
        child: Text(
          'No saman history found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) => _buildVehicleCard(vehicles[index]),
      );
  }
}
