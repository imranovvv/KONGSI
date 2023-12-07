import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Balances extends StatefulWidget {
  final String groupId;

  const Balances({Key? key, required this.groupId}) : super(key: key);

  @override
  State<Balances> createState() => _BalancesState();
}

class _BalancesState extends State<Balances> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('Group not found');
          }

          final Map<String, dynamic>? groupData =
              snapshot.data!.data() as Map<String, dynamic>?;

          if (groupData == null || !groupData.containsKey('members')) {
            return const Text('No members found for this group');
          }

          final Map<String, dynamic> members =
              groupData['members'] as Map<String, dynamic>;

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final MapEntry<String, dynamic> memberEntry =
                  members.entries.elementAt(index);

              final String memberName = memberEntry.key;

              return ListTile(
                title: Text(memberName),
              );
            },
          );
        },
      ),
    );
  }
}
