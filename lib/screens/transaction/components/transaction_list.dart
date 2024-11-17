import 'package:client/screens/transaction/transaction_detail.dart';
import 'package:flutter/material.dart';
import 'package:client/screens/transaction/components/transaction.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class TransactionList extends StatefulWidget {
  final String userId; // Pass the user ID when navigating to HomePage

  const TransactionList({Key? key, required this.userId}) : super(key: key);

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  List<Transaction> transList = [];
  bool isLoading = true; // Loading indicator
  String errorMessage = ''; // For displaying any error that occurs

  @override
  void initState() {
    super.initState();
    _fetchTransactionList(); // Fetch transactions when the widget initializes
  }

  Future<void> _fetchTransactionList() async {
    try {
      final baseUrl = dotenv.env["FLUTTER_APP_BACKEND_URL"];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final url = Uri.parse('$baseUrl/transaction/${widget.userId}/list');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('transaction')) {
          setState(() {
            transList = List<Transaction>.from(
              data['transaction'].map(
                    (transaction) => Transaction(
                  id: transaction['_id']?.toString() ?? '',
                  money: (transaction['money'] is int
                      ? (transaction['money'] as int).toDouble()
                      : transaction['money']) ??
                      0.0, // Ensure valid number
                  date: transaction['date'] ?? 'No Date', // Default 'No Date' if missing
                  status: transaction['status'] ?? 'Unknown', // Default 'Unknown' if missing
                  deliver: transaction['deliver'] ?? 'Unknown', // Default 'Unknown' if missing
                ),
              ),
            ).whereType<Transaction>().toList(); // Filter out invalid transactions
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'No transactions found for the user.';
          });
        }
      } else {
        throw Exception('Failed to load transaction data: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
      setState(() {
        isLoading = false;
        errorMessage = 'Error occurred: $error';
      });
    }
  }

  Widget _buildTransactionTile(Transaction trans) {
    // Determine icon and color based on the transaction status
    final isInTransaction = trans.status == 'in';
    final iconData = isInTransaction ? Icons.arrow_upward : Icons.arrow_downward;
    final iconColor = isInTransaction ? Colors.green : Colors.red;
    final iconBackgroundColor = iconColor.withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransactionDetail(
                  money: trans.money,
                  date: trans.date,
                  status: trans.status,
                  deliver: trans.deliver,
                ),
              ),
            );
          },
          child: ListTile(
            leading: Container(
              decoration: BoxDecoration(
                color: iconBackgroundColor, // Background color
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                iconData,
                color: iconColor,
                size: 30,
              ),
            ),
            title: Text(
              'RM ${trans.money.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            subtitle: Text(trans.date),
            trailing: const Icon(Icons.remove_red_eye_outlined),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transList.isNotEmpty
          ? ListView.builder(
        itemCount: transList.length,
        itemBuilder: (context, index) =>
            _buildTransactionTile(transList[index]),
      )
          : Center(
        child: Text(
          errorMessage.isNotEmpty ? errorMessage : 'No transactions available.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
