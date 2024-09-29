import 'package:client/screens/Login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:client/screens/Home%20Page/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding JSON responses

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

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
                  _icon(),
                  SizedBox(height: 50),
                  _inputField("Username", usernameController),
                  SizedBox(height: 20),
                  _inputField("Email", emailController),
                  SizedBox(height: 20),
                  _inputField("Password", passwordController, isPassword: true),
                  SizedBox(height: 20),
                  _inputField("Phone Number", phoneController),
                  SizedBox(height: 50),
                  _registerButton(),
                  if (errorMessage.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
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

  Widget _icon() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 120,
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

  Widget _registerButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleRegister,
      child: SizedBox(
        width: double.infinity,
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.blue))
            : Text(
          "Sign Up",
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

  Future<void> _handleRegister() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    final name = usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    // Debug: Print the payload being sent to the backend
    final payload = {
      'email': email,
      'password': password,
      'name': name,
      'no_telephone': phone
    };
    print('Payload being sent: $payload');

    try {
      // Correctly construct the URL with the base URL from .env
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      print('Sending request to: $baseUrl/users/register'); // Print the URL for debugging

      final response = await http.post(
        Uri.parse('$baseUrl/users/register'), // Correct URL construction
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload), // Send the constructed payload
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        // Assuming a successful response from the server
        final data = jsonDecode(response.body);

        if (data['token'] != null) {
          // Store the token if required
          String token = data['token'];
          print('Token: $token');

          // Navigate to the home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Registration failed, please try again.';
          });
        }
      } else {
        // Capture and display backend error messages
        final errorData = jsonDecode(response.body);
        setState(() {
          errorMessage = errorData['message'] ?? 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      print('Error occurred: $e'); // Print the actual error for debugging
      setState(() {
        errorMessage = 'An error occurred. Please check your connection and try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Widget _extraText() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      },
      child: Text(
        "Already have an account?",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
