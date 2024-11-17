import 'package:client/screens/Home%20Page/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class PayPalForm extends StatefulWidget {
  final String userId;
  final String amount;

  const PayPalForm({Key? key, required this.userId, required this.amount}) : super(key: key);

  @override
  State<PayPalForm> createState() => _PayPalFormState();
}

class _PayPalFormState extends State<PayPalForm> {
  bool _isLoading = false;
  String? _paymentStatus;
  WebViewController? _webViewController;

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
        final orderID = responseData["orderID"];
        _showPayPalWebView(approvalLink, orderID);
      } else {
        setState(() {
          _paymentStatus = "Payment initiation failed";
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

  void _showPayPalWebView(String approvalLink, String orderID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 500,
            child: WebView(
              initialUrl: approvalLink,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onPageStarted: (String url) {
                print("Page started loading: $url");

                if (url.contains('paypal-success')) {
                  Navigator.pop(context); // Close WebView dialog
                  _capturePayment(orderID); // Capture payment after user approval
                } else if (url.contains('paypal-cancel')) {
                  Navigator.pop(context); // Close WebView dialog
                  setState(() {
                    _paymentStatus = "Payment canceled";
                  });
                }
              },
              navigationDelegate: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },
            ),
          ),
        );
      },
    );
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

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)),
        );
      } else {
        setState(() {
          print("Response Data: $responseData");
          _paymentStatus = "Payment failed";
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)),
        );
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
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _processPayPalPayment,
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
