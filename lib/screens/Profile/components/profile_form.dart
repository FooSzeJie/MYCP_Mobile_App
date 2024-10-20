import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:client/components/input_field.dart';
import 'package:client/components/dialog.dart';

class ProfileForm extends StatefulWidget {
  final String userId;  // Accept the userId from HomePage

  const ProfileForm({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isLoading = true;  // Loading indicator

  @override
  void initState() {
    super.initState();
    _fetchProfileInformation();  // Fetch the profile when the widget is initialized
  }

  // Get the data from backend
  Future<void> _fetchProfileInformation() async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final url = Uri.parse('$baseUrl/users/${widget.userId}/profile');

      final response = await http.get(url);

      // print("Response status: ${response.statusCode}");
      // print("Response body: ${response.body}");  // Print the response body

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('user')) {
          setState(() {
            // Update the text in each controller
            nameController.text = data['user']['name'] ?? '';
            passwordController.text = '';  // Never prefill the password
            phoneController.text = data['user']['no_telephone'].toString() ?? '';
            emailController.text = data['user']['email'] ?? '';
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load profile information');
      }
    } catch (error) {
      print('Error occurred: $error');
      setState(() {
        isLoading = false;  // Stop loading even if there's an error
      });
    }
  }

  // Update the data to the backend
  Future<void> _handleUpdateProfile() async {
    final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

    try {
      final url = Uri.parse('$baseUrl/users/${widget.userId}/profile/update');
      Map<String, dynamic> body = {
        'name': nameController.text,
        'no_telephone': phoneController.text,
      };

      // Only send the password if it's filled in
      if (passwordController.text.isNotEmpty) {
        body['password'] = passwordController.text;
      }

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Show the Dialog
        showDialogBox(
          context,
          title: 'Updated Successfully',       // Optional: Custom title
          message: "You are successfully updated the profile.",  // Required: Error message
        );

      } else {
        throw Exception('Failed to update profile');
      }
    } catch (error) {
      print('Error updating profile: $error');

      // Show the Dialog
      showDialogBox(
        context,
        title: 'Updated Failed',       // Optional: Custom title
        message: "Error updating profile. Please try again.",  // Required: Error message
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());  // Show loading indicator
    }

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          InputField(controller: nameController, hintText: 'Name'),

          SizedBox(height: 10),

          InputField(controller: passwordController, hintText: 'Password', isPassword: true),

          SizedBox(height: 10),

          InputField(controller: phoneController, hintText: 'Phone Number'),

          SizedBox(height: 10),

          InputField(controller: emailController, hintText: 'Email', isEmail: true, enabled: false,),

          SizedBox(height: 30),

          ElevatedButton(
            onPressed: _handleUpdateProfile,
            child: Text("Update"),
          ),
        ],
      ),
    );
  }
}
