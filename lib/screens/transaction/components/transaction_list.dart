import 'package:client/screens/transaction/transaction_detail.dart';
import 'package:flutter/material.dart';
import 'package:client/screens/transaction/components/transaction.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {

  final List<Transaction> transList = [
    Transaction(10, 10, '2015-07-21'),
    Transaction(20, 20, '2017-09-01'),
    Transaction(30, 30, '2015-10-29'),
    Transaction(10, 10, '2015-12-30'),
    Transaction(10, 10, '2015-09-15'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: ListView(
        children: transList.map((trans) {
          return Padding(
            padding:  EdgeInsets.all(2.0),
            child: Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => TransactionDetail(token: trans.token, money: trans.money, top_up_date: trans.top_up_date)
                      ));
                },
                child: ListTile(
                  leading: FittedBox(
                    child: CircleAvatar(
                      child: Text('RM${trans.money}'),
                      radius: 30,
                    ),
                  ),

                  title: Text(
                    '${trans.token} Tokens',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    trans.top_up_date,
                  ),

                  trailing: Icon(Icons.remove_red_eye_outlined),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
