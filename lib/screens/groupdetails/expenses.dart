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

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CupertinoSearchTextField(
                  placeholder: 'Search',
                  onSubmitted: (String value) {
                    // Handle search when the user submits the text.
                    print('Search: $value');
                  },
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {
                  // Handle the tune button press.
                  print('Tune button pressed');
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
                      title: Text(
                        expense.id,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                            Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
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
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        "My Total:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("RM 300"),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        "Total:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("RM 500"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 80,
          )
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
