import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kongsi/screens/groupdetails/addexpense.dart';

import 'dart:math' as math;

class Transactions extends StatefulWidget {
  final String groupId;

  const Transactions({Key? key, required this.groupId}) : super(key: key);

  @override
  TransactionsState createState() => TransactionsState();
}

class TransactionsState extends State<Transactions> {
  @override
  void initState() {
    super.initState();
    loadCurrencySymbol();
  }

  String currencySymbol = '\$';

  Future<String> getCurrencyCode(String groupId) async {
    var groupSnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get();
    return groupSnapshot.data()?['currency'] ?? 'USD';
  }

  Future<void> loadCurrencySymbol() async {
    String currencyCode = await getCurrencyCode(widget.groupId);
    final jsonString = await rootBundle.loadString('assets/currency.json');
    final jsonResponse = json.decode(jsonString) as Map<String, dynamic>;
    setState(() {
      currencySymbol = jsonResponse[currencyCode]['symbol_native'] ?? '\$';
    });
  }

  Stream<List<Transaction>> fetchTransactionsStream() {
    var groupExpenses = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('expenses');

    return groupExpenses.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            var data = doc.data();
            String paidBy = data['paidBy'];
            var debtors = data['debtors'] as Map;

            return debtors.entries
                .where((entry) => entry.key != paidBy)
                .map((entry) => Transaction(entry.key, paidBy,
                    double.tryParse(entry.value.toString()) ?? 0.0))
                .toList();
          })
          .expand((element) => element)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Transaction>>(
          stream: fetchTransactionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No Transactions Found'));
            }

            var transactions = simplifyDebts(snapshot.data!);

            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                var transaction = transactions[index];
                return Column(
                  children: [
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.black,
                                  child: Icon(CupertinoIcons.person_badge_plus),
                                ),
                                Text(
                                  transaction.debtor,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                                  style:
                                      const TextStyle(color: Color(0xff10416d)),
                                ),
                                const Icon(
                                  CupertinoIcons.arrow_right,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.black,
                                  child: Icon(CupertinoIcons.person),
                                ),
                                Text(
                                  transaction.creditor,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: _buildReimburseButton(transaction),
                    ),
                    const Divider(
                        color: Colors.grey, thickness: 1.0, height: 0.0),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Transaction> simplifyDebts(List<Transaction> transactions) {
    var netBalances = <String, double>{};

    // Calculate net balances
    for (var transaction in transactions) {
      netBalances[transaction.debtor] =
          (netBalances[transaction.debtor] ?? 0) - transaction.amount;
      netBalances[transaction.creditor] =
          (netBalances[transaction.creditor] ?? 0) + transaction.amount;
    }

    // Separate into creditors and debtors
    var creditors = <String, double>{};
    var debtors = <String, double>{};
    netBalances.forEach((person, amount) {
      if (amount > 0) {
        creditors[person] = amount;
      } else if (amount < 0) {
        debtors[person] = -amount;
      }
    });

    // Simplify debts
    var simplifiedDebts = <Transaction>[];
    while (debtors.isNotEmpty && creditors.isNotEmpty) {
      var debtor = debtors.keys.first;
      var creditor = creditors.keys.first;
      var debtAmount = debtors[debtor]!;
      var creditAmount = creditors[creditor]!;

      var payment = math.min(debtAmount, creditAmount);
      simplifiedDebts.add(Transaction(debtor, creditor, payment));

      debtors[debtor] = debtAmount - payment;
      if (debtors[debtor]! <= 0) {
        debtors.remove(debtor);
      }

      creditors[creditor] = creditAmount - payment;
      if (creditors[creditor]! <= 0) {
        creditors.remove(creditor);
      }
    }

    return simplifiedDebts;
  }

  Widget _buildReimburseButton(Transaction transaction) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[600],
        elevation: 0,
        padding: const EdgeInsets.all(4),
      ),
      onPressed: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => AddExpense(
              groupId: widget.groupId,
              title: 'Reimbursement',
              paidBy: transaction.debtor,
              debtor: transaction.creditor,
              amount: transaction.amount,
            ),
          ),
        );
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Reimburse", style: TextStyle(fontSize: 14)),
          SizedBox(width: 4),
          Icon(CupertinoIcons.money_dollar_circle, size: 24),
        ],
      ),
    );
  }
}

class Transaction {
  String debtor;
  String creditor;
  double amount;

  Transaction(this.debtor, this.creditor, this.amount);
}
