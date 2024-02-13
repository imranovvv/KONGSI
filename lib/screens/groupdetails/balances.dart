import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Balances extends StatefulWidget {
  final String groupId;

  const Balances({Key? key, required this.groupId}) : super(key: key);

  @override
  State<Balances> createState() => _BalancesState();
}

class Expense {
  final String title;
  final double amount;
  final String paidBy;
  final DateTime date;
  Map<String, double> debtors;

  Expense(
      {required this.title,
      required this.amount,
      required this.paidBy,
      required this.date,
      required this.debtors});
}

class MemberBalance {
  String name;
  double balance;
  RangeValues rangeValues;

  MemberBalance(this.name, this.balance)
      : rangeValues = const RangeValues(0.5, 0.5);
}

class _BalancesState extends State<Balances> {
  bool isLoading = true;
  String? userName;

  @override
  void initState() {
    super.initState();
    getUserData();

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

  Stream<List<MemberBalance>> fetchMembersAndBalancesStream(
      String groupId) async* {
    var members = await fetchGroupMembers(groupId);
    var expensesCollection = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('expenses');

    await for (var snapshot in expensesCollection.snapshots()) {
      List<MemberBalance> memberBalances = [];
      double totalBalance = 0;

      for (var memberName in members.keys) {
        double balance = 0;
        for (var doc in snapshot.docs) {
          var data = doc.data();
          Expense expense = Expense(
            title: data['title'],
            amount: data['amount'],
            paidBy: data['paidBy'],
            date: DateTime.parse(data['date']),
            debtors: Map<String, double>.from(data['debtors']),
          );

          if (expense.paidBy == memberName) {
            balance += expense.amount;
          }
          balance -= (expense.debtors[memberName] ?? 0);
        }
        totalBalance += balance.abs();
        memberBalances.add(MemberBalance(memberName, balance));
      }

      for (var memberBalance in memberBalances) {
        if (totalBalance == 0) {
          memberBalance.rangeValues = const RangeValues(0.5, 0.5);
        } else {
          double valuePart = (memberBalance.balance.abs() / totalBalance);
          if (memberBalance.balance >= 0) {
            memberBalance.rangeValues = RangeValues(0.5, 0.5 + valuePart);
          } else {
            memberBalance.rangeValues = RangeValues(0.5 - valuePart, 0.5);
          }
        }
      }

      yield memberBalances;
    }
  }

  Future<Map<String, dynamic>> fetchGroupMembers(String groupId) async {
    var groupDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get();

    if (!groupDoc.exists || groupDoc.data() == null) {
      throw Exception('Group not found');
    }

    var groupData = groupDoc.data()!;
    if (!groupData.containsKey('members')) {
      throw Exception('No members found for this group');
    }

    return groupData['members'] as Map<String, dynamic>;
  }

  SliderTheme _buildSliderWidget(MemberBalance data) {
    Color activeTrackColor = data.balance > 0 ? Colors.green : Colors.red;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
          activeTrackColor: activeTrackColor,
          inactiveTrackColor: Colors.grey,
          thumbColor: Colors.black,
          rangeThumbShape:
              const _CustomRangeSliderThumbShape(), // Updated to use custom shape

          trackShape: const RectangularSliderTrackShape(),
          overlayShape: SliderComponentShape.noThumb),
      child: AbsorbPointer(
        absorbing: true,
        child: RangeSlider(
          values: data.rangeValues,
          onChanged: (values) => {},
          min: 0.0,
          max: 1.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<MemberBalance>>(
          stream: fetchMembersAndBalancesStream(widget.groupId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CupertinoActivityIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No members found for this group');
            }

            var memberBalances = snapshot.data!;

            return ListView.builder(
              itemCount: memberBalances.length,
              itemBuilder: (context, index) {
                final memberBalance = memberBalances[index];

                String displayName = memberBalance.name == userName
                    ? "${memberBalance.name} (me)"
                    : memberBalance.name;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(displayName),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              (memberBalance.balance < 0
                                      ? '-$currencySymbol'
                                      : currencySymbol) +
                                  memberBalance.balance
                                      .abs()
                                      .toStringAsFixed(2),
                              style: TextStyle(
                                color: memberBalance.balance < 0
                                    ? Colors.red[800]
                                    : Colors.green[800],
                              ),
                            ),
                            _buildSliderWidget(memberBalance),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CustomRangeSliderThumbShape extends RangeSliderThumbShape {
  const _CustomRangeSliderThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(10, 30); // Width and height of the thumb
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    TextDirection textDirection = TextDirection.ltr,
    required SliderThemeData sliderTheme,
    Thumb thumb = Thumb.start,
    bool isPressed = false,
  }) {
    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor! // Color of the thumb
      ..style = PaintingStyle.fill;
    final Rect rect = Rect.fromCenter(
        center: center,
        width: 1.5,
        height: 10); // Adjust width and height accordingly
    context.canvas.drawRect(rect, paint);
  }
}
