import 'package:client/screens/Home%20Page/home_screen.dart';
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to a specific page when the back button is pressed
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(userId: widget.userId), // Replace `HomePage` with your desired page
              ),
            );
          },
        ),
      ),
      body: ProfileForm(userId: widget.userId),
    );
  }
}
