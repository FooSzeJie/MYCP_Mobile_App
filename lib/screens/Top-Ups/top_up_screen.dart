import 'package:client/screens/Top-Ups/components/top_up_form.dart';
import 'package:flutter/material.dart';

class TopUpScreen extends StatefulWidget {
  final String userId;

  const TopUpScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Top up"),
      ),
      body: TopUpForm(userId: widget.userId),
    );
  }
}
