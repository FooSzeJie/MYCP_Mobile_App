import 'package:client/screens/Top-Ups/top_up_screen.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
      decoration: BoxDecoration(color: Color(0xFF674AEF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Icon(
          //       Icons.dashboard,
          //       size: 30,
          //       color: Colors.white,
          //     ),
          //
          //     Icon(
          //       Icons.notifications,
          //       size: 30,
          //       color: Colors.white,
          //     ),
          //   ],
          // ),

          SizedBox(height: 20,),

          // Padding(padding: EdgeInsets.only(left: 3, bottom: 15), child: Text(
          //   "Hi User, ",
          //   style: TextStyle(
          //     fontSize: 25,
          //     fontWeight: FontWeight.w600,
          //     letterSpacing: 1,
          //     wordSpacing: 2,
          //     color: Colors.white,
          //   ),
          // ),
          // ),

          Container(
            child: Text(
              "RM 10.00",
              style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            ),
          ),

          SizedBox(height: 10,),

          Container(
            margin: EdgeInsets.only(top: 5, bottom: 20),
            width: 300,
            height: 55,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30)
            ),

            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => TopUpScreen()
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
          )
        ],
      ),
    );
  }
}
