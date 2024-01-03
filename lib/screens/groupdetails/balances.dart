import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

class SliderData {
  int balance;
  late RangeValues rangeValues;

  SliderData({required this.balance});
}

class _BalancesState extends State<Balances> {
  List<SliderData> slidersData = [];
  Map<String, dynamic>? members;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGroupMembersAndBalances();
  }

  void fetchGroupMembersAndBalances() async {
    try {
      members = await fetchGroupMembers(widget.groupId);
      if (members != null) {
        for (var memberName in members!.keys) {
          double balance =
              await calculateBalance(widget.groupId, memberName).first;
          slidersData.add(SliderData(balance: balance.toInt()));
        }
        calculateRangeValues();
      }
    } catch (e) {
      // Handle exceptions
    }
    setState(() {
      isLoading = false;
    });
  }

  void calculateRangeValues() {
    double total =
        slidersData.fold(0, (sum, data) => sum + data.balance.abs()).toDouble();

    for (var sliderData in slidersData) {
      if (total == 0 || sliderData.balance == 0) {
        // Neutral position when total balance or individual balance is zero
        sliderData.rangeValues = RangeValues(0.5, 0.5);
      } else {
        double valuePart = sliderData.balance.abs() / total;
        if (sliderData.balance >= 0) {
          sliderData.rangeValues = RangeValues(0.5, 0.5 + valuePart);
        } else {
          sliderData.rangeValues = RangeValues(0.5 - valuePart, 0.5);
        }
      }
    }
  }

  SliderTheme _buildSliderWidget(SliderData data) {
    Color activeTrackColor = data.balance > 0 ? Colors.green : Colors.red;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeTrackColor,
        inactiveTrackColor: Colors.grey,
        thumbColor: Colors.black,
        rangeThumbShape:
            const RoundRangeSliderThumbShape(enabledThumbRadius: 4.0),
        trackShape: const RectangularSliderTrackShape(),
      ),
      child: AbsorbPointer(
        absorbing: true,
        child: RangeSlider(
          values: data.rangeValues,
          onChanged: (values) => _onSliderChanged(values, data),
          min: 0.0,
          max: 1.0,
        ),
      ),
    );
  }

  void _onSliderChanged(RangeValues values, SliderData data) {
    setState(() {
      data.rangeValues = values;
    });
  }

  Stream<double> calculateBalance(String groupId, String userId) {
    var expensesCollection = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('expenses');

    return expensesCollection.snapshots().map((snapshot) {
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

        if (expense.paidBy == userId) {
          balance += expense.amount;
        }

        balance -= (expense.debtors[userId] ?? 0);
      }

      return balance;
    });
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchGroupMembers(widget.groupId),
        builder: (context, membersSnapshot) {
          if (membersSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (membersSnapshot.hasError) {
            return Text('Error: ${membersSnapshot.error}');
          }

          final members = membersSnapshot.data;

          if (members == null) {
            return const Text('No members found for this group');
          }

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final String memberName = members.keys.elementAt(index);

              return StreamBuilder<double>(
                stream: calculateBalance(widget.groupId, memberName),
                builder: (context, balanceSnapshot) {
                  if (balanceSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                      title: Text(memberName),
                      subtitle: const Text('Calculating balance...'),
                    );
                  }

                  if (balanceSnapshot.hasError) {
                    return ListTile(
                      title: Text(memberName),
                      subtitle: Text('Error: ${balanceSnapshot.error}'),
                    );
                  }

                  final double balance = balanceSnapshot.data ?? 0.0;
                  return ListTile(
                    title: Text(memberName),
                    subtitle: Text('Balance: \$${balance.toStringAsFixed(2)}'),
                    trailing: SizedBox(
                      width: 200,
                      child: _buildSliderWidget(slidersData[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
