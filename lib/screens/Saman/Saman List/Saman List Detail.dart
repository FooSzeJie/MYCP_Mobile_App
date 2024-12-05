import 'package:client/components/dialog.dart';
import 'package:client/screens/Saman/Saman%20List/saman_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SamanListDetail extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> saman;

  const SamanListDetail({Key? key, required this.userId, required this.saman})
      : super(key: key);

  @override
  State<SamanListDetail> createState() => _SamanListDetailState();
}

class _SamanListDetailState extends State<SamanListDetail> {
  bool isLoading = false;
  String errorMessage = '';

  Future<void> _paySaman() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final localAuthority = "MBJB";

    final payload = {
      "name" : "Paid Saman",
      "money": widget.saman['price']?.toStringAsFixed(2),
      'deliver': localAuthority,
      'creator': widget.userId,
    };

    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set in the .env file.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/transaction/create/saman'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        await _changeStatus();

        await _sendEmail();

        showDialogBox(
          context,
          title: 'Pay Saman Successfully',
          message: 'You are Successfully pay the saman.',
        );

        // Delay navigation to allow the dialog box to display
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SamanListScreen(userId: widget.userId)),
          );
        });

      } else {

        showDialogBox(
          context,
          title: 'Pay Saman Fail',
          message: 'You are Fail to pay the saman.',
        );
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _changeStatus() async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final url = Uri.parse('$baseUrl/saman/${widget.saman['id']}/paid');
      final response = await http.patch(url);

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to Pay Saman: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
      setState(() {
        errorMessage = 'Error occurred: $error';
      });
    }
  }

  Future<void> _sendEmail() async {
    final payload = {
      'subject': "MYCP Paid Saman",
      'message': "You are already Paid RM${widget.saman['price']} for Saman"
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
    final saman = widget.saman;
    final isPaid = saman['status'] == 'paid';

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Offense: ${saman['offense'] ?? 'Unknown'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Date: ${saman['date'] ?? 'Unknown'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Amount: RM${saman['price']?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Status: ${saman['status']?.toUpperCase() ?? 'UNKNOWN'}',
              style: TextStyle(
                fontSize: 16,
                color: isPaid ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            if (!isPaid)
              ElevatedButton(
                onPressed: isLoading ? null : _paySaman,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Pay Saman',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
          ],
        ),
      );
  }
}
