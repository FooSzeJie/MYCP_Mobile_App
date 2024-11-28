import 'package:client/screens/transaction/transaction_detail.dart';
import 'package:flutter/material.dart';
import 'package:client/screens/transaction/components/transaction.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting

class TransactionList extends StatefulWidget {
  final String userId;

  const TransactionList({Key? key, required this.userId}) : super(key: key);

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  List<Transaction> transList = [];
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
    _fetchTransactionList(); // Fetch today's transactions
  }

  Future<void> _fetchTransactionList() async {
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
          '$baseUrl/transaction/${widget.userId}/list?start_date=$startDateString&end_date=$endDateString');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('transaction')) {
          setState(() {
            transList = List<Transaction>.from(
              data['transaction'].map(
                    (transaction) => Transaction(
                  id: transaction['_id']?.toString() ?? '',
                  name: transaction['name']?.toString() ?? '',
                  money: (transaction['money'] is int
                      ? (transaction['money'] as int).toDouble()
                      : transaction['money']) ??
                      0.0,
                  date: transaction['date'] ?? 'No Date',
                  status: transaction['status'] ?? 'Unknown',
                  deliver: transaction['deliver'] ?? 'Unknown',
                ),
              ),
            ).whereType<Transaction>().toList();
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

  void _selectDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020), // Adjust to the earliest possible date
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

      // Fetch filtered transactions
      _fetchTransactionList();
    }
  }

  Widget _buildTransactionTile(Transaction trans) {
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
                  name: trans.name,
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
                color: iconBackgroundColor,
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
              '${trans.name} (RM ${trans.money.toStringAsFixed(2)})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            subtitle: Text(
              'Date: ${trans.date}\nDeliver: ${trans.deliver}',
            ),
            trailing: const Icon(Icons.remove_red_eye_outlined),
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
                "Transactions (${DateFormat('yyyy-MM-dd').format(selectedStartDate!)} to ${DateFormat('yyyy-MM-dd').format(selectedEndDate!)})",
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
              : transList.isNotEmpty
              ? ListView.builder(
            itemCount: transList.length,
            itemBuilder: (context, index) =>
                _buildTransactionTile(transList[index]),
          )
              : Center(
            child: Text(
              errorMessage.isNotEmpty
                  ? errorMessage
                  : 'No transactions available.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
