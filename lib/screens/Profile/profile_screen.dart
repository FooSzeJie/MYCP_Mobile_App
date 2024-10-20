import 'package:client/screens/Profile/components/profile_form.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {

  final String userId;  // Pass the user ID when navigating to HomePage

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);  // Constructor with userId

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Profile"),
      ),
      body: ProfileForm(userId: widget.userId),
    );
  }
}
