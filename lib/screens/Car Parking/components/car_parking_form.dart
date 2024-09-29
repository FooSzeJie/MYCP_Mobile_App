import 'package:flutter/material.dart';

class CarParkingForm extends StatefulWidget {
  const CarParkingForm({super.key});

  @override
  State<CarParkingForm> createState() => _CarParkingFormState();
}

class _CarParkingFormState extends State<CarParkingForm> {

  TextEditingController carController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  final durations = [30, 60, 120, 180, 240, 360];
  int? selectedDuration;

  final vehicle = ['ABC1234', 'QWE8089', 'WFC9587'];
  String? selectedCar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15, right: 8, left: 8, bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Duration:",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.7)
                ),
              ),

              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: DropdownButton<int>(
                      value: selectedDuration,
                      iconSize: 36,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black,),
                      items: durations.map(buildIntMenuItem).toList(),
                      onChanged: (durationValue) {
                        setState(() {
                          this.selectedDuration = durationValue;
                          durationController.text = '${durationValue}'; // Update the controller with the selected value
                        });
                      },
                    ),
                  ),

                  Text("Minutes"),
                ],
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Cars:",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.7)
                ),
              ),

              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCar,
                      iconSize: 36,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                      items: vehicle.map(buildStringMenuItem).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCar = value;
                          carController.text = value!;// Update the controller with the selected value
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 10,),

          // TextField(
          //   controller: addressController,
          //   decoration: InputDecoration(
          //     hintText: "Password",
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.all(Radius.circular(10)),
          //     ),
          //   ),
          // ),

          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Row(
              children: [
                Text(
                  "Area: ",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black.withOpacity(0.3)
                  ),
                ),

                Text(
                  "Skudai",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black.withOpacity(0.3)
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10,),

          SizedBox(height: 30,),

          ElevatedButton(
              onPressed: () {},
              child: Text("Parking")),
        ],
      ),
    );
  }

  DropdownMenuItem<int> buildIntMenuItem(int item) => DropdownMenuItem(
    value: item,
    child: Text(
      '${item}',
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 20
      ),
    ),
  );

  DropdownMenuItem<String> buildStringMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 20
      ),
    ),
  );
}
