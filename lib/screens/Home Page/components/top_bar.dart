import 'package:client/screens/Top-Ups/top_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class TopBar extends StatefulWidget {
  final String userId;  // Accept the userId from HomePage

  const TopBar({Key? key, required this.userId}) : super(key: key);

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String walletBalance = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();  // Fetch the balance when the widget is initialized
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final baseUrl = dotenv.env['FLUTTER_APP_BACKEND_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Backend URL is not set correctly in the .env file.');
      }

      final url = Uri.parse('$baseUrl/users/${widget.userId}/profile');

      final response = await http.get(url);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}"); // Print the response body

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Decoded response data: $data"); // Print the decoded response

        setState(() {
          // Check the structure of the data before accessing 'wallet'
          walletBalance = "RM ${data['user']['wallet'].toStringAsFixed(2)}";
        });
      } else {
        print("Failed to fetch wallet balance. Status code: ${response.statusCode}");
        setState(() {
          walletBalance = "GET Error";
        });
      }
    } catch (error) {
      print('Error occurred: $error');
      setState(() {
        walletBalance = "Code Error";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
      decoration: BoxDecoration(
        color: Color(0xFF674AEF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Container(
            child: Text(
              walletBalance,  // Display the fetched wallet balance
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 20),
            width: 300,
            height: 55,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => TopUpScreen(),
                ));
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.add,
                      size: 30,
                    ),
                  ),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                      child: Text(
                        "Top Up",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
