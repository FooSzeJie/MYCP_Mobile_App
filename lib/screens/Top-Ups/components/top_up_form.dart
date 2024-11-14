import 'package:client/screens/Top-Ups/card_form/card_form_screen.dart';
import 'package:client/screens/Top-Ups/card_form/paypal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class TopUpForm extends StatefulWidget {
  final String userId;

  const TopUpForm({Key? key, required this.userId}) : super(key: key);

  @override
  State<TopUpForm> createState() => _TopUpFormState();
}

class _TopUpFormState extends State<TopUpForm> {
  final TextEditingController moneyController = TextEditingController();

  final List<int> moneys = [10, 20, 50, 100, 200];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      child: Column(
        children: [
          // TextField with custom formatter
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

          const SizedBox(height: 10), // Space between TextField and ListView

          // Horizontal ListView of predefined amounts
          Container(
            height: 40, // Slightly increased height for better UI spacing
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: moneys.length,
              itemBuilder: (context, index) {
                final amount = moneys[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    onPressed: () {
                      // Set the moneyController text to the predefined amount as a formatted string
                      moneyController.text = amount.toStringAsFixed(2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button background color
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

          const SizedBox(height: 50), // Space above the "Top Up" button

          // Top Up button
          ElevatedButton(
            onPressed: () {
              final amount = moneyController.text;
              print('Amount: RM $amount');
              // Navigate to CardFormScreen or next screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaypalScreen(userId: widget.userId, amount: amount),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(double.infinity, 50), // Full-width button
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Top Up",
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
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
    // Remove any non-numeric characters
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Convert to double for currency formatting
    double value = double.parse(newText) / 100;

    // Format as currency with two decimal places
    String formattedValue = value.toStringAsFixed(2);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
