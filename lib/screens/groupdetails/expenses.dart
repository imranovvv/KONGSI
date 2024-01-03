import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final Map<String, double> debtors;

  Expense({
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.date,
    required this.debtors,
  });
}

class _ExpensesState extends State<Expenses> {
  String? userName;
  TextEditingController searchController = TextEditingController();
  String? searchQuery;
  late Stream<List<Expense>> expensesStream;

  @override
  void initState() {
    super.initState();
    getUserData();
    expensesStream = getExpensesStream(widget.groupId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();
      var members = groupSnapshot['members'];
      members.forEach((name, uid) {
        if (uid == user.uid) {
          setState(() => userName = name);
        }
      });
    }
  }

  void updateSearchQuery(String newQuery) {
    setState(() => searchQuery = newQuery.toLowerCase());
  }

  double calculateTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (total, expense) => total + expense.amount);
  }

  double calculateUserTotal(List<Expense> expenses, String userName) {
    return expenses.fold(0.0, (total, expense) {
      if (expense.paidBy == userName) {
        return total + expense.amount;
      } else {
        return total + (expense.debtors[userName] ?? 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          buildSearchBar(),
          buildExpensesList(),
          buildTotalDisplay(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: CupertinoSearchTextField(
            controller: searchController,
            placeholder: 'Search',
            onChanged: updateSearchQuery,
            decoration: const BoxDecoration(color: Colors.transparent),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.tune),
          onPressed: () => print('Tune button pressed'),
        ),
      ],
    );
  }

  Widget buildExpensesList() {
    return Expanded(
      child: StreamBuilder<List<Expense>>(
        stream: expensesStream,
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

          var expenses = filterExpenses(snapshot.data!);
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) => buildExpenseTile(expenses[index]),
          );
        },
      ),
    );
  }

  List<Expense> filterExpenses(List<Expense> expenses) {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return expenses
          .where(
              (expense) => expense.title.toLowerCase().contains(searchQuery!))
          .toList();
    }
    return expenses;
  }

  Widget buildExpenseTile(Expense expense) {
    return Column(
      children: [
        ListTile(
          title: Text(expense.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(DateFormat('dd/MM/yyyy').format(expense.date),
              style: const TextStyle(
                  fontStyle: FontStyle.italic, color: Color(0xFF10416D))),
          trailing: buildExpenseAmountDisplay(expense),
        ),
        const Divider(color: Colors.grey, thickness: 1.0, height: 0.0),
      ],
    );
  }

  Widget buildExpenseAmountDisplay(Expense expense) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          Text('\$${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(expense.paidBy,
              style: const TextStyle(
                  fontStyle: FontStyle.italic, color: Color(0xFF10416D))),
        ],
      ),
    );
  }

  Widget buildTotalDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildUserTotalDisplay(),
          buildGroupTotalDisplay(),
        ],
      ),
    );
  }

  Widget buildUserTotalDisplay() {
    return StreamBuilder<List<Expense>>(
      stream: getExpensesStream(widget.groupId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Calculating...");
        }

        double userTotal = userName != null
            ? calculateUserTotal(snapshot.data!, userName!)
            : 0.0;

        return buildTotalContainer("My Total", userTotal);
      },
    );
  }

  Widget buildGroupTotalDisplay() {
    return StreamBuilder<List<Expense>>(
      stream: getExpensesStream(widget.groupId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Calculating...");
        }

        double totalAmount = calculateTotal(snapshot.data!);
        return buildTotalContainer("Total", totalAmount);
      },
    );
  }

  Widget buildTotalContainer(String label, double amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("RM ${amount.toStringAsFixed(2)}"),
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
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            var data = doc.data();
            return Expense(
              title: data['title'],
              amount: data['amount'],
              paidBy: data['paidBy'],
              date: DateTime.parse(data['date']),
              debtors: Map<String, double>.from(data['debtors'] ?? {}),
            );
          }).toList());
}
