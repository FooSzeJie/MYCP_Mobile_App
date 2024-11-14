import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class PayPalForm extends StatefulWidget {
  final String userId;
  final String amount;

  const PayPalForm({Key? key, required this.userId, required this.amount}) : super(key: key);

  @override
  State<PayPalForm> createState() => _PayPalFormState();
}

class _PayPalFormState extends State<PayPalForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  bool _isLoading = false;
  String? _paymentStatus;

  @override
  void initState() {
    super.initState();
    amountController.text = widget.amount;
    nameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    amountController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = nameController.text.isNotEmpty &&
          amountController.text.isNotEmpty &&
          _formKey.currentState?.validate() == true;
    });
  }

  Future<void> _processPayPalPayment() async {
    setState(() {
      _isLoading = true;
      _paymentStatus = null;
    });

    final payload = {
      'money': widget.amount,
    };

    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set in the .env file.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/transaction/${widget.userId}/paypal'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 201 && responseData["approvalLink"] != null) {
        final approvalLink = responseData["approvalLink"];

        // Redirect user to PayPal approval page
        if (await canLaunch(approvalLink)) {
          await launch(approvalLink);

          // After user approval, attempt capture (this should be triggered after user returns)
          await _capturePayment(responseData["orderID"]);
        } else {
          throw Exception("Could not launch PayPal approval link");
        }
      } else {
        setState(() {
          _paymentStatus = "Payment Failed";
        });
      }
    } catch (error) {
      setState(() {
        _paymentStatus = "Error: $error";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _capturePayment(String orderID) async {
    final capturePayload = {'orderID': orderID};

    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      final response = await http.post(
        Uri.parse('$baseUrl/transaction/${widget.userId}/paypal/capture'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(capturePayload),
      );

      final responseData = json.decode(response.body);
      if (responseData["success"] == true) {
        setState(() {
          _paymentStatus = "Payment Successful!";
        });
      } else {
        setState(() {
          _paymentStatus = "Payment Failed";
        });
      }
    } catch (error) {
      setState(() {
        _paymentStatus = "Error capturing payment: $error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Amount",
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _isFormValid ? _processPayPalPayment : null,
            child: Text("Pay with PayPal"),
          ),
          if (_paymentStatus != null) ...[
            SizedBox(height: 20),
            Text(_paymentStatus!),
          ],
        ],
      ),
    );
  }
}
