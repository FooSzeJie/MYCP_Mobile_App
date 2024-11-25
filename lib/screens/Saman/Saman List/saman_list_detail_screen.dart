import 'package:client/screens/Home%20Page/home_screen.dart';
import 'package:client/screens/Saman/Saman%20Form/saman_form.dart';
import 'package:client/screens/Saman/Saman%20List/Saman%20List%20Detail.dart';
import 'package:client/screens/Saman/Saman%20List/saman_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SamanListDetailScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> saman;

  const SamanListDetailScreen({Key? key, required this.userId, required this.saman}) : super(key: key);

  @override
  State<SamanListDetailScreen> createState() => _SamanListDetailScreenState();
}

class _SamanListDetailScreenState extends State<SamanListDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Saman List Detail"),
      ),

      body: SamanListDetail(userId: widget.userId, saman: widget.saman),
    );
  }
}
