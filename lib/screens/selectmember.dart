import 'package:flutter/material.dart';
import 'package:kongsi/components/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectMember extends StatefulWidget {
  final List<String> members;
  final String groupId;

  const SelectMember({Key? key, required this.members, required this.groupId})
      : super(key: key);

  @override
  State<SelectMember> createState() => _SelectMemberState();
}

class _SelectMemberState extends State<SelectMember> {
  late final List<String> members;
  String groupName = "";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    members = widget.members;
    fetchGroupName();
    print(currentUser!.uid);
  }

  void fetchGroupName() async {
    try {
      DocumentSnapshot groupSnapshot =
          await firestore.collection('groups').doc(widget.groupId).get();
      Map<String, dynamic> groupData =
          groupSnapshot.data() as Map<String, dynamic>;
      setState(() {
        groupName = groupData['groupname'] ?? "";
      });
    } catch (e) {
      print('$e');
    }
  }

  void popTwoPages(BuildContext context) {
    int count = 0;
    Navigator.popUntil(context, (_) => count++ >= 2);
  }

  void selectMember(String memberName) async {
    if (currentUser != null && groupName.isNotEmpty) {
      String userId = currentUser!.uid;
      String memberField = 'members.$memberName';

      await firestore
          .collection('groups')
          .doc(widget.groupId)
          .update({memberField: userId});

      Map<String, dynamic> groupInfo = {
        'id': widget.groupId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await firestore.collection('users').doc(userId).set({
        'groups': {groupName: groupInfo}
      }, SetOptions(merge: true));

      if (!mounted) return;
      popTwoPages(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        showLogoutButton: false,
        showDoneButton: false,
      ),
      body: Column(
        children: [
          AppBar(
            centerTitle: true,
            title: Text('Join $groupName',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text('Select a member to join the group'),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(members[index]),
                          ),
                          ElevatedButton(
                            onPressed: () => selectMember(members[index]),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Select'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
