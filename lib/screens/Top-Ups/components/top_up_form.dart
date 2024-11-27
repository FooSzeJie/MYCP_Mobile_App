import 'package:client/screens/Home%20Page/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/components/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class TopUpForm extends StatefulWidget {
  final String userId;

  const TopUpForm({Key? key, required this.userId}) : super(key: key);

  @override
  State<TopUpForm> createState() => _TopUpFormState();
}

class _TopUpFormState extends State<TopUpForm> {
  final TextEditingController moneyController = TextEditingController();
  final List<int> moneys = [10, 20, 50, 100, 200];
  String? _paymentStatus;
  bool _isLoading = false;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    moneyController.addListener(() {
      setState(() {}); // Update the form UI whenever input changes
    });
  }

  Future<void> _processPayPalPayment() async {
    setState(() {
      _isLoading = true;
      _paymentStatus = null;
    });

    final payload = {'money': moneyController.text};

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
              onWebViewCreated: (controller) => _webViewController = controller,
              onPageStarted: (url) {
                if (url.contains('paypal-success')) {
                  Navigator.pop(context); // Close WebView dialog
                  _capturePayment(orderID);
                } else if (url.contains('paypal-cancel')) {
                  Navigator.pop(context); // Close WebView dialog
                  setState(() {
                    _paymentStatus = "Payment canceled";
                  });
                }
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
        await _sendEmail();

        showDialogBox(
          context,
          title: 'Success',
          message: 'Payment Successfully.',
        );

        // Delay navigation to allow the dialog box to display
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)),
          );
        });
      } else {
        showDialogBox(
          context,
          title: 'Failed',
          message: 'Payment Failed.',
        );

        // Delay navigation to allow the dialog box to display
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)),
          );
        });
      }
    } catch (error) {
      setState(() {
        _paymentStatus = "Error capturing payment: $error";
      });
    }
  }

  Future<void> _sendEmail() async {
    final payload = {
      'subject': "MYCP Top Up",
      'message': "You are already Top up RM${moneyController} to the MyCP APP"
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
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      child: Column(
        children: [
          TextField(
            controller: moneyController,
            decoration: InputDecoration(
              hintText: "Enter amount",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixText: 'RM ',
              prefixStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 25),
            inputFormatters: [
              CurrencyInputFormatter(),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: moneys.length,
              itemBuilder: (context, index) {
                final amount = moneys[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    onPressed: () {
                      moneyController.text = amount.toStringAsFixed(2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'RM $amount',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 50),

          ElevatedButton(
            onPressed: moneyController.text.isNotEmpty ? _processPayPalPayment : null,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Top Up",
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),

          if (_isLoading) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

// Custom formatter for currency with 2 decimal places
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    double value = double.parse(newText) / 100;
    String formattedValue = value.toStringAsFixed(2);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
