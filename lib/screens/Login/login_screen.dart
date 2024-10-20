import 'package:client/screens/Home%20Page/home_screen.dart';
import 'package:client/screens/Login/components/login_icon.dart';
import 'package:client/screens/Register/register_screen.dart';
import 'package:client/components/dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert'; // For decoding JSON responses

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false; // To manage loading state
  String errorMessage = ''; // To display error messages

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue,
            Colors.red,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoginIcon(),
                  SizedBox(height: 50),
                  _inputField("Email", emailController),
                  SizedBox(height: 20),
                  _inputField("Password", passwordController, isPassword: true),

                  SizedBox(height: 50),

                  _loginButton(),

                  SizedBox(height: 20),

                  _extraText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller, {bool isPassword = false}) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colors.white),
    );

    return TextField(
      style: TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white),
        enabledBorder: border,
        focusedBorder: border,
      ),
      obscureText: isPassword,
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleLogin,
      child: SizedBox(
        width: double.infinity,
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.blue))
            : Text(
          "Sign In",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
      style: ElevatedButton.styleFrom(
        shape: StadiumBorder(),
        primary: Color.fromARGB(255, 228, 226, 226),
        onPrimary: Colors.blue,
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  // Handles the login process
  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        isLoading = false;
      });

      // Show the Dialog
      showDialogBox(
        context,
        title: 'Login Fail',       // Optional: Custom title
        message: 'Please fill in both email and password.',  // Required: Error message
      );

      return;
    }

    try {
      // Correctly construct the URL with the base URL from .env
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      // print('Sending request to: $baseUrl/users/login'); // Print the URL for debugging

      final response = await http.post(
        Uri.parse('$baseUrl/users/login'), // Correct URL construction
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Check if the login is successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if a token and userId are returned
        if (data['token'] != null && data['userId'] != null) {
          String userId = data['userId']; // Extract userId from response

          // print(userId);

          // Navigate to the home screen and pass the userId
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(userId: userId)), // Pass userId to HomePage
          );
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Invalid credentials, please try again.';
          });

          // Show the Dialog
          showDialogBox(
            context,
            title: 'Login Fail',       // Optional: Custom title
            message: errorMessage,  // Required: Error message
          );
        }
      } else {
        // Show the Dialog
        showDialogBox(
          context,
          title: 'Login Fail',       // Optional: Custom title
          message: 'Login failed. Please try again.',  // Required: Error message
        );
      }
    } catch (e) {
      print('Error occurred: $e'); // Print the actual error for debugging
      // Show the Dialog
      showDialogBox(
        context,
        title: 'Login Fail',       // Optional: Custom title
        message: 'An error occurred. Please check your connection and try again.',  // Required: Error message
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _extraText() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
      },
      child: Text(
        "Haven't registered an account?",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
