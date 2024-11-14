import 'package:client/screens/Top-Ups/card_form/card_form.dart';
import 'package:client/screens/Top-Ups/card_form/payment.dart';
import 'package:flutter/material.dart';

class CardFormScreen extends StatefulWidget {
  final String userId;
  final String amount;

  const CardFormScreen({Key? key, required this.userId, required this.amount}) : super(key: key);
  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Card Form"),
      ),
      // body: CardForm(userId: widget.userId, amount: widget.amount,),
      // body: PaymentScreen(userId: widget.userId, amount: widget.amount,),
    );
  }
}
