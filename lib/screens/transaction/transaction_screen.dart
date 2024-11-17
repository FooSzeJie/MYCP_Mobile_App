import 'package:client/screens/transaction//components/transaction_list.dart';
import 'package:flutter/material.dart';

class TransactionScreen extends StatefulWidget {
  final String userId;  // Pass the user ID when navigating to HomePage

  const TransactionScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Transaction",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      body: TransactionList(userId: widget.userId),
    );
  }
}

