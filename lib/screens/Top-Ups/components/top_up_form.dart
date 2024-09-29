import 'package:flutter/material.dart';

class TopUpForm extends StatelessWidget {
  TextEditingController moneyController = TextEditingController();

  final List<int> moneys = [10, 20, 50, 100, 200];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15, right: 8, left: 8, bottom: 8),
      child: Column(
        children: [
          TextField(
            controller: moneyController,
            decoration: InputDecoration(
              hintText: "Enter amount",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              prefixText: 'RM ',
              prefixStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 25,
            ),
          ),

          SizedBox(height: 10),  // Space between TextField and ListView

          Container(
            height: 30,  // Fixed height for ListView
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: moneys.length,
              itemBuilder: (context, index) {
                final amount = moneys[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    onPressed: () {
                      moneyController.text = amount.toString();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'RM $amount',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 50),

          ElevatedButton(
            onPressed: () {
              print('Amount: RM ${moneyController.text}');
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Top Up",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
