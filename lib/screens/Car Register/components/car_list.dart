import 'package:client/screens/Car%20Register/components/car.dart';
import 'package:flutter/material.dart';

class CarList extends StatelessWidget {
  List<Car> cars = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return cars.isEmpty ? Text(
      'No Cars yet...',
      style: TextStyle(fontSize: 22),
    ) : Expanded(
      child: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) => getRow(index),
      ),
    );
  }

  Widget getRow(int index) {
    return ListTile(
      title: Column(
        children: [
          Text(cars[index].licensePlate),
          Text(cars[index].color)
        ],
      ),
    );
  }
}


