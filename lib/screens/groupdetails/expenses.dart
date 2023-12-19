import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Expenses extends StatefulWidget {
  final String groupId;

  const Expenses({Key? key, required this.groupId}) : super(key: key);

  @override
  State<Expenses> createState() => _ExpensesState();
}

class Expense {
  final String title;
  final double amount;
  final String paidBy;
  final DateTime date;

  Expense(
      {required this.title,
      required this.amount,
      required this.paidBy,
      required this.date});
}

class _ExpensesState extends State<Expenses> {
  @override
  void initState() {
    super.initState();
    stream =
        getExpensesStream(widget.groupId); // Initialize the stream in initState
  }

  TextEditingController searchController = TextEditingController();
  String? searchQuery;

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery.toLowerCase();
    });
  }

  double calculateTotal(List<Expense> expenses) {
    double total = 0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  late Stream<List<Expense>> stream; // Declare the stream here

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
                  controller: searchController,
                  placeholder: 'Search',
                  onChanged: updateSearchQuery,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {
                  print('Tune button pressed');
                },
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No expenses found');
                }

                List<Expense> expenses = snapshot.data!;
                if (searchQuery != null && searchQuery!.isNotEmpty) {
                  expenses = expenses
                      .where((expense) =>
                          expense.title.toLowerCase().contains(searchQuery!))
                      .toList();
                }

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            expense.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy').format(expense.date),
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  expense.paidBy,
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
                      Text("RM 500"),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: StreamBuilder<List<Expense>>(
                    stream: getExpensesStream(widget.groupId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("Calculating...");
                      }

                      double totalAmount = calculateTotal(snapshot.data!);
                      return Column(
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("RM ${totalAmount.toStringAsFixed(2)}"),
                        ],
                      );
                    },
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

Stream<List<Expense>> getExpensesStream(String groupId) {
  return FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('expenses')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            var data = doc.data();
            return Expense(
              title: data['title'],
              amount: data['amount'],
              paidBy: data['paidBy'],
              date: DateTime.parse(data['date']),
            );
          }).toList());
}
