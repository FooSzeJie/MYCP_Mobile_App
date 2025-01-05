import 'package:flutter/material.dart';
import 'package:client/screens/Car Parking/components/Parking.dart';

class ParkingDetail extends StatelessWidget {
  final String license_plate;
  final String start_date;
  final String end_date;
  final int duration;
  final String deliver;

  const ParkingDetail({super.key,
    required this.license_plate,
    required this.start_date,
    required this.end_date,
    required this.duration,
    required this.deliver,});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Parking Detail",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ListView(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: Icon(Icons.car_rental, size: 150, color: Colors.white,),
                ),

                SizedBox(height: 50,),

                Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "License Plate",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black.withOpacity(0.7)
                          ),
                        ),

                        Text(
                          "${this.license_plate}",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Duration",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black.withOpacity(0.7)
                          ),
                        ),

                        Text(
                          "${this.duration} Minutes",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Deliver to",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black.withOpacity(0.7)
                          ),
                        ),

                        Text(
                          deliver,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Starting Date",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black.withOpacity(0.7)
                          ),
                        ),

                        Text(
                          "${this.start_date}",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ending Date",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black.withOpacity(0.7)
                          ),
                        ),

                        Text(
                          "${this.end_date}",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
      );
    }
  }
