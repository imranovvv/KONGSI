import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kongsi/screens/groupdetails/expensedetail.dart';

class Expenses extends StatefulWidget {
  final String groupId;

  const Expenses({Key? key, required this.groupId}) : super(key: key);

  @override
  State<Expenses> createState() => _ExpensesState();
}

class Expense {
  final String expenseId;
  final String title;
  final double amount;
  final String paidBy;
  final DateTime date;
  final Map<String, double> debtors;
  final DateTime createdAt;

  Expense({
    required this.expenseId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.date,
    required this.debtors,
    required this.createdAt,
  });
}

enum SortOption {
  title,
  amount,
  date,
  paidBy,
}

class _ExpensesState extends State<Expenses> {
  String? userName;
  TextEditingController searchController = TextEditingController();
  String? searchQuery;
  late Stream<List<Expense>> expensesStream;
  String currencySymbol = '';
  SortOption currentSortOption = SortOption.date;
  bool isDescending = false;

  @override
  void initState() {
    super.initState();
    getUserData();
    expensesStream = getExpensesStream(widget.groupId);
    loadCurrencySymbol();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Expense> sortExpenses(
      List<Expense> expenses, SortOption sortOption, bool descending) {
    Comparator<Expense> comparator;
    switch (sortOption) {
      case SortOption.title:
        comparator =
            (b, a) => a.title.toUpperCase().compareTo(b.title.toUpperCase());
        break;

      case SortOption.amount:
        comparator = (a, b) => a.amount.compareTo(b.amount);
        break;
      case SortOption.date:
        comparator = (a, b) => a.createdAt.compareTo(b.createdAt);
        break;

      case SortOption.paidBy:
        comparator = (b, a) => a.paidBy.compareTo(b.paidBy);
        break;
    }
    expenses.sort(comparator);
    if (!descending) {
      expenses = expenses.reversed.toList();
    }
    return expenses;
  }

  String describeSortOption(SortOption option) {
    switch (option) {
      case SortOption.title:
        return 'Title';
      case SortOption.amount:
        return 'Amount';
      case SortOption.date:
        return 'Date';
      case SortOption.paidBy:
        return 'Paid By';
      default:
        return 'Unknown';
    }
  }

  Future<String> getCurrencyCode(String groupId) async {
    var groupSnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get();
    return groupSnapshot.data()?['currency'];
  }

  Future<void> loadCurrencySymbol() async {
    String currencyCode = await getCurrencyCode(widget.groupId);
    final jsonString = await rootBundle.loadString('assets/currency.json');
    final jsonResponse = json.decode(jsonString) as Map<String, dynamic>;
    if (mounted) {
      setState(() {
        currencySymbol = jsonResponse[currencyCode]['symbol_native'];
      });
    }
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
        if (mounted) {
          if (uid == user.uid) {
            setState(() => userName = name);
          }
        }
      });
    }
  }

  void updateSearchQuery(String newQuery) {
    setState(() => searchQuery = newQuery.toLowerCase());
  }

  double calculateTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (total, expense) {
      if (expense.title.toLowerCase() != 'reimbursement') {
        return total + expense.amount;
      }
      return total;
    });
  }

  double calculateUserTotal(List<Expense> expenses, String userName) {
    return expenses.fold(0.0, (total, expense) {
      if (expense.title.toLowerCase() != 'reimbursement') {
        return total + (expense.debtors[userName] ?? 0.0);
      }
      return total;
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
        PopupMenuButton<SortOption>(
          icon: const Icon(Icons.sort),
          onSelected: (SortOption option) {
            setState(() {
              if (currentSortOption == option) {
                isDescending = !isDescending;
              } else {
                currentSortOption = option;
                isDescending = false;
              }
            });
          },
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          itemBuilder: (BuildContext context) =>
              SortOption.values.map((option) {
            return PopupMenuItem<SortOption>(
              value: option,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(describeSortOption(option)),
                  if (currentSortOption == option)
                    Icon(
                      isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 20.0,
                    ),
                ],
              ),
            );
          }).toList(),
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
            return const Center(
              child: Text(
                "You don't have any expenses yet. Click the \"+\" button to add them.",
                textAlign: TextAlign.center,
              ),
            );
          }
          var expenses = filterExpenses(snapshot.data!);
          expenses = sortExpenses(expenses, currentSortOption, isDescending);

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) =>
                buildExpenseTile(expenses[index], expenses[index].expenseId),
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

  Widget buildExpenseTile(Expense expense, String documentId) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 100,
              color: Colors.white,
              child: Center(
                child: ListTile(
                  leading: const Icon(CupertinoIcons.delete, color: Colors.red),
                  title: const Text('Delete Expense'),
                  onTap: () {
                    deleteExpense(widget.groupId, documentId);
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) =>
                    ExpenseDetail(expense, currencySymbol, userName!)),
          );
        },
        child: Column(
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
        ),
      ),
    );
  }

  // Widget buildExpenseTile(Expense expense, String documentId) {
  //   Color tileColor = Theme.of(context).cardColor;

  //   return CupertinoContextMenu.builder(
  //     actions: [
  //       CupertinoContextMenuAction(
  //         onPressed: () {
  //           Navigator.pop(context);
  //           deleteExpense(widget.groupId, documentId);
  //         },
  //         isDestructiveAction: true,
  //         trailingIcon: CupertinoIcons.delete,
  //         child: const Text('Delete'),
  //       ),
  //     ],
  //     builder: (BuildContext context, Animation<double> animation) {
  //       final Animation<Decoration> boxDecorationAnimation =
  //           _boxDecorationAnimation(animation);

  //       return Container(
  //         decoration: animation.value < CupertinoContextMenu.animationOpensAt
  //             ? boxDecorationAnimation.value
  //             : null,
  //         child: Column(
  //           children: [
  //             ListTile(
  //               title: Text(expense.title,
  //                   style: const TextStyle(fontWeight: FontWeight.bold)),
  //               subtitle: Text(DateFormat('dd/MM/yyyy').format(expense.date),
  //                   style: const TextStyle(
  //                       fontStyle: FontStyle.italic, color: Color(0xFF10416D))),
  //               trailing: buildExpenseAmountDisplay(expense),
  //             ),
  //             const Divider(color: Colors.grey, thickness: 1.0, height: 0.0),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<void> deleteExpense(String groupId, String documentId) async {
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .doc(documentId)
        .delete();
  }

  Widget buildExpenseAmountDisplay(Expense expense) {
    String paidByDisplay =
        expense.paidBy == userName ? "${expense.paidBy} (me)" : expense.paidBy;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          Text('$currencySymbol${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(paidByDisplay,
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
          Text("$currencySymbol${amount.toStringAsFixed(2)}"),
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
              expenseId: doc.id,
              title: data['title'],
              amount: data['amount'],
              paidBy: data['paidBy'],
              date: DateTime.parse(data['date']),
              debtors: Map<String, double>.from(data['debtors'] ?? {}),
              createdAt: data['createdAt'].toDate(),
            );
          }).toList());
}
