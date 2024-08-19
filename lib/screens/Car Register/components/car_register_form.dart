import 'package:client/screens/Car%20Register/components/car.dart';
import 'package:client/screens/Car%20Register/components/car_list.dart';
import 'package:flutter/material.dart';

class CarRegisterForm extends StatefulWidget {

  @override
  State<CarRegisterForm> createState() => _CarRegisterFormState();
}

class _CarRegisterFormState extends State<CarRegisterForm> {
  TextEditingController licensePlateController = TextEditingController();

  TextEditingController colorController = TextEditingController();

  List<Car> cars = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          TextField(
            controller: licensePlateController,
            maxLength: 8,
            decoration: InputDecoration(
              hintText: "License Plate Number",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),

          SizedBox(height: 10,),

          TextField(
            controller: colorController,
            decoration: InputDecoration(
              hintText: "Car Color",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),

          SizedBox(height: 10,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    String licensePlate = licensePlateController.text.trim();
                    String color = colorController.text.trim();

                    if(licensePlate.isNotEmpty && color.isNotEmpty) {
                      setState(() {
                        cars.add(
                            Car(
                                licensePlate: licensePlate,
                                color: color
                            )
                        );
                      });
                    }
                  },
                  child: Text("Save")),

              ElevatedButton(
                  onPressed: () {},
                  child: Text("Update")),
            ],
          ),

          SizedBox(height: 10,),

        cars.isEmpty ? Text(
        'No Cars yet...',
        style: TextStyle(fontSize: 22),
        ) : Expanded(
        child: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) => getRow(index),
        ),
        )
        ],
      ),
    );
  }
  Widget getRow(int index) {
  return Card(
    color: Colors.grey[200],
    child: ListTile(
      // leading: CircleAvatar(
      //   backgroundColor: index %2 == 0 ? Colors.deepPurpleAccent : Colors.purple,
      //   foregroundColor: Colors.white,
      //   child: Text(cars[index].licensePlate[0]),
      // ),

      title: Column(
        children: [
          Text(
            cars[index].licensePlate,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
          Text(cars[index].color)
        ],
      ),

      trailing: SizedBox(
        width: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: (() {}),
              child: Icon(
                Icons.edit,
                size: 35,)
            ),

            InkWell(
              onTap: (() {
                setState(() {
                  cars.removeAt(index);
                });
              }),
              child: Icon(Icons.delete, size: 35,)
            ),
          ],
        ),
      ),
    ),
  );
}
}
