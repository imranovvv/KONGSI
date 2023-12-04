import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<String>>(
        stream: getUserGroupsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CupertinoActivityIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            var groups = snapshot.data ?? [];
            return StreamBuilder<List<String>>(
              stream: getGroupMembers(groups),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CupertinoActivityIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  var members = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(members[index]),
                        // You can customize the ListTile further based on your requirements
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}

Stream<List<String>> getUserGroupsStream() async* {
  User? user = FirebaseAuth.instance.currentUser;
  String? userId = user?.uid;
  if (userId != null) {
    var userDocument =
        FirebaseFirestore.instance.collection('users').doc(userId);
    yield* userDocument.snapshots().map((snapshot) {
      var groupMap =
          Map<String, dynamic>.from(snapshot.data()?['groups'] ?? {});
      var groupNames = groupMap.keys.toList();
      print(groupNames); // Print group members
      return groupNames;
    }).asyncMap((groupNames) async {
      return groupNames;
    });
  } else {
    yield [];
  }
}

Stream<List<String>> getGroupMembers(List<String> groupValues) async* {
  for (var groupName in groupValues) {
    var groupDocument =
        FirebaseFirestore.instance.collection('groups').doc(groupName);

    yield* groupDocument.snapshots().map((snapshot) {
      var members = List<String>.from(snapshot.data()?['members'] ?? []);
      print('Group Members for $groupName: $members'); // Print group members

      return members;
    }).asyncMap((members) async {
      // You can perform additional asynchronous operations here if needed
      return members;
    });
  }
}
