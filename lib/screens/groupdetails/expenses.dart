import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _Expenses();
}

class _Expenses extends State<Expenses> {
  List<Expense> expenses = [
    Expense(
      id: 'expense_id_1',
      description: "Dinner at a restaurant",
      amount: 100.00,
      payer: 'user_id_1',
      group: 'group_id_1',
      splitType: "equal",
    ),
    Expense(
      id: 'expense_id_1',
      description: "Dinner at a restaurant",
      amount: 100.00,
      payer: 'user_id_1',
      group: 'group_id_1',
      splitType: "equal",
    ),
    // Add more expenses as needed
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Column(
          children: <Widget>[
            ListTile(
              title: Text(expense.id),
              subtitle: Text(expense.description),
              trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
            ),
            const Divider(
              color: Colors.grey, // You can customize the color
              thickness: 1.0, // You can adjust the thickness
              height:
                  0.0, // You can control the space above and below the divider
            ),
          ],
        );
      },
    );
  }
}

class Expense {
  final String id;
  final String description;
  final double amount;
  final String payer;
  final String group;
  final String splitType;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.payer,
    required this.group,
    required this.splitType,
  });
}
