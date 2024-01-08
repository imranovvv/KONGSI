import 'package:flutter/material.dart';

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  TransactionsState createState() => TransactionsState();
}

class TransactionsState extends State<Transactions> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Transaction',
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
      ),
    );
  }
}
