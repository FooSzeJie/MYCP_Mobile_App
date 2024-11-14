import 'package:client/screens/Top-Ups/card_form/card_form.dart';
import 'package:client/screens/Top-Ups/card_form/payment.dart';
import 'package:flutter/material.dart';

class PaypalScreen extends StatefulWidget {
  final String userId;
  final String amount;

  const PaypalScreen({Key? key, required this.userId, required this.amount}) : super(key: key);
  @override
  State<PaypalScreen> createState() => _PaypalScreenState();
}

class _PaypalScreenState extends State<PaypalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Paypal Checkout"),
      ),
      // body: CardForm(userId: widget.userId, amount: widget.amount,),
      body: PayPalForm(userId: widget.userId, amount: widget.amount,),
    );
  }
}
