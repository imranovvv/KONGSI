import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    getUserData();
    loadCurrencySymbol();
  }

  String currencySymbol = '\$';
  String? userName;

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
        child: Column(
          children: [
            StreamBuilder<List<Transaction>>(
              stream: fetchTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Expanded(
                    child: Center(child: Text('Everyone\'s debt is settled')),
                  );
                }

                var transactions = simplifyDebts(snapshot.data!);

                if (transactions.isEmpty) {
                  return const Expanded(
                    child: Center(child: Text("Everyone's debt is settled")),
                  );
                }

                var userTransactions = transactions
                    .where((transaction) => transaction.debtor == userName)
                    .toList();
                var otherTransactions = transactions
                    .where((transaction) => transaction.debtor != userName)
                    .toList();

                return Expanded(
                  child: ListView.builder(
                    itemCount: userTransactions.length +
                        otherTransactions.length +
                        (otherTransactions.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < userTransactions.length) {
                        return Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'My debt',
                              ),
                            ),
                            _buildTransactionTile(userTransactions[index]),
                          ],
                        );
                      } else if (index == userTransactions.length &&
                          otherTransactions.isNotEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(child: Text('Other members\' debt')),
                        );
                      } else {
                        return _buildTransactionTile(otherTransactions[
                            index - userTransactions.length - 1]);
                      }
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
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

  Widget _buildTransactionTile(Transaction transaction) {
    String debtorName = transaction.debtor == userName
        ? "${transaction.debtor} (me)"
        : transaction.debtor;
    String creditorName = transaction.creditor == userName
        ? "${transaction.creditor} (me)"
        : transaction.creditor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
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
                        debtorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('owes'),
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
                        creditorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Text(
              '$currencySymbol${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xff10416d), fontSize: 16),
            ),
          ),
          const Divider(color: Colors.grey, thickness: 1.0, height: 0.0),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: _buildReimburseButton(transaction),
            ),
          ),
        ],
      ),
    );
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
              isReimbursement: true,
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
