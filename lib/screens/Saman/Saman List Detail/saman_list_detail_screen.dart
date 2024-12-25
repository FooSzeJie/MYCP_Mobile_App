import 'package:flutter/material.dart';
import 'package:client/screens/Saman/Saman%20List%20detail/saman_list_detail.dart';

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
