import 'package:flutter/cupertino.dart';
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
      date: DateTime.now(),
      amount: 100.00,
      payer: 'Ali',
      group: 'group_id_1',
      splitType: "equal",
    ),
  ];

  bool isSearching = false; // Track the visibility of the search field
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (isSearching)
            CupertinoSearchTextField(
              controller: searchController,
              onChanged: (value) {},
              onSubmitted: (value) {
                setState(() {
                  isSearching = false;
                });
              },
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Icon(
                    CupertinoIcons.search,
                    color: Colors.black, // Set the color to black
                  ),
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                ),
                CupertinoButton(
                  child: const Icon(
                    Icons.tune,
                    color: Colors.black, // Set the color to black
                  ),
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                ),
              ],
            ),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(expense.id),
                      subtitle: Text(
                        expense.date.toString(),
                        style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF10416D)),
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            Text('\$${expense.amount.toStringAsFixed(2)}'),
                            Text(
                              expense.payer,
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF10416D)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                      height: 0.0,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Expense {
  final String id;
  final DateTime date;
  final double amount;
  final String payer;
  final String group;
  final String splitType;

  Expense({
    required this.id,
    required this.date,
    required this.amount,
    required this.payer,
    required this.group,
    required this.splitType,
  });
}
