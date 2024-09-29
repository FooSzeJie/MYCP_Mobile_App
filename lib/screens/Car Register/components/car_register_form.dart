import 'package:client/screens/Car%20Register/components/car.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CarRegisterForm extends StatefulWidget {

  @override
  State<CarRegisterForm> createState() => _CarRegisterFormState();
}

class _CarRegisterFormState extends State<CarRegisterForm> {
  TextEditingController licensePlateController = TextEditingController();

  TextEditingController colorController = TextEditingController();

  TextEditingController brandController = TextEditingController();

  List<Car> cars = List.empty(growable: true);

  final colors = ['White', 'Black', 'Red', 'Orange', 'Yellow', 'Green', 'Blue', 'Purple', 'Silver'];
  String? selectedColor;

  final brands = ['Perodua', 'Totyota', 'Honda', 'Misutbisi', 'Mercedes-Benz', 'BMW', 'Audi', 'Proton', 'Tesla'];
  String? selectedBrand;

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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Car Color:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.7)
                ),
              ),

              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: DropdownButton<String>(
                    value: selectedColor,
                    iconSize: 36,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black,),
                    items: colors.map(buildMenuItem).toList(),
                    onChanged: (value) {
                      setState(() {
                        this.selectedColor = value;
                        colorController.text = value!; // Update the controller with the selected value
                      });
                    },
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Car Brand:",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.7)
                ),
              ),

              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: DropdownButton<String>(
                  value: selectedBrand,
                  iconSize: 36,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black,),
                  items: brands.map(buildMenuItem).toList(),
                  onChanged: (value) {
                    setState(() {
                      this.selectedBrand = value;
                      brandController.text = value!; // Update the controller with the selected value
                    });
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 10,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    String licensePlate = licensePlateController.text.trim();
                    String color = colorController.text.trim();
                    String brand = brandController.text.trim();

                    if(licensePlate.isNotEmpty && color.isNotEmpty) {
                      setState(() {
                        cars.add(
                            Car(
                                licensePlate: licensePlate,
                                color: color,
                                brand: brand
                            )
                        );

                        print(color);
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
          Text(cars[index].color),
          Text(cars[index].brand)
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

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 20
      ),
    ),
  );

}
