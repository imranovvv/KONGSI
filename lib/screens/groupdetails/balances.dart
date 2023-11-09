import 'package:flutter/material.dart';

class Member {
  final String name;
  final double balance;

  Member({required this.name, required this.balance});
}

class Balances extends StatefulWidget {
  const Balances({Key? key}) : super(key: key);

  @override
  State<Balances> createState() => _BalancesState();
}

class _BalancesState extends State<Balances> {
  // Sample list of members
  final List<Member> members = [
    Member(name: 'Member 1', balance: 100.0),
    Member(name: 'Member 2', balance: -50.0),
    Member(name: 'Member 3', balance: 75.0),
    Member(name: 'Member 4', balance: -30.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];

          return Container(
            height: 100,
            child: ListTile(
              title: Text(member.name),
              trailing: Column(
                children: [
                  // Expanded(
                  //   child: Slider(
                  //     value: member.balance,
                  //     min: -100,
                  //     max: 100,
                  //     onChanged: (value) {
                  //       // Handle slider value change if needed
                  //     },
                  //   ),
                  // ),
                  Text(
                    member.balance.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
