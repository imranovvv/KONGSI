import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kongsi/components/appbar.dart';
import 'package:kongsi/screens/selectmember.dart';

class JoinGroup extends StatefulWidget {
  const JoinGroup({super.key});

  @override
  State<JoinGroup> createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
  final TextEditingController groupIdController = TextEditingController();
  Future<List<String>>? membersFuture;
  String? errorMessage;

  Future<List<String>> fetchGroupData(String groupId) async {
    if (groupId.isEmpty) {
      return [];
    }

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (!snapshot.exists) {
        setState(() => errorMessage = "Group does not exist");
        return [];
      }

      Map<String, dynamic>? data = snapshot.data();
      if (data != null && data['members'] is Map) {
        var membersMap = data['members'] as Map<String, dynamic>;
        return membersMap.keys.where((key) => membersMap[key].isEmpty).toList();
      } else {
        setState(() => errorMessage = "Invalid group data");
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  Widget _buildJoinButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff10416d),
        elevation: 0,
      ),
      onPressed: () {
        setState(() {
          membersFuture = fetchGroupData(groupIdController.text);
        });
      },
      child: const Text("Join", style: TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(showLogoutButton: false),
      body: Stack(
        children: [
          AppBar(
            centerTitle: true,
            title: const Text('Join Group',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoTextField(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0, 1),
                            blurRadius: 4)
                      ],
                    ),
                    placeholder: 'Paste the invitation link',
                    controller: groupIdController,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.poppins(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    prefix: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.link)),
                  ),
                  const SizedBox(height: 20),
                  if (errorMessage != null)
                    Text(errorMessage!,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 16)),
                  const SizedBox(height: 20),
                  _buildJoinButton(),
                ],
              ),
            ),
          ),
          if (membersFuture != null)
            FutureBuilder<List<String>>(
              future: membersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    String groupId = groupIdController.text;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => SelectMember(
                              members: snapshot.data!, groupId: groupId)));
                    });
                  }
                  return const SizedBox();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
        ],
      ),
    );
  }
}
