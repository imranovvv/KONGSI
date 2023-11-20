import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:kongsi/screens/groupdetailpage.dart';
import 'package:kongsi/screens/joingroup.dart';
import 'package:kongsi/screens/newgroup.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

bool isSelected = true;

class _HomeState extends State<Home> {
  TextEditingController searchController = TextEditingController();

  List<String> filteredGroupNames = [];

  @override
  void initState() {
    super.initState();
  }

  void signOut() async {
    Navigator.of(context).pop();

    FirebaseAuth.instance.signOut();
  }

  List<String> userGroupNames = [];

  final stream = getUserGroupsStream();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SpeedDial(
        backgroundColor: const Color(0xff10416d),
        children: [
          SpeedDialChild(
            child: const Icon(CupertinoIcons.person_add_solid),
            label: 'New Group',
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const NewGroup()),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(CupertinoIcons.person_2_fill),
            label: 'Join Group',
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const JoinGroup()),
              );
            },
          ),
        ],
        onOpen: () {
          setState(() {
            isSelected = !isSelected;
          });
        },
        onClose: () {
          setState(() {
            isSelected = !isSelected;
          });
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: isSelected
              ? const Icon(Icons.add, key: Key('addIcon'))
              : const Icon(Icons.clear, key: Key('clearIcon')),
        ),
      ),

      body: Column(
        children: [
          AppBar(
            centerTitle: true,
            title: const Text(
              'My Groups',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Balance: ',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                'RM150',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 30, right: 30, top: 16, bottom: 16),
            child: Center(
              child: CupertinoSearchTextField(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.white,
                ),
                controller: searchController,
                style: GoogleFonts.poppins(),
              ),
            ),
          ),
          StreamBuilder<List<String>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CupertinoActivityIndicator();
              } else if (snapshot.hasError) {
                return Text(
                    'Error: ${snapshot.error}'); // Show an error message if there's an error
              } else {
                var groupIds = snapshot.data ?? [];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CupertinoScrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: groupIds.length,
                        itemBuilder: (context, index) {
                          Color tileColor = index.isOdd
                              ? const Color(0xffECECEC)
                              : Colors.white;
                          return GestureDetector(
                            onTap: () {
                              // Navigate to the new page when the user clicks the forward button
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => GroupDetailPage(
                                      groupName: groupIds[index]),
                                ),
                              );
                            },
                            child: Card(
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                tileColor: tileColor,
                                title: buildGroupNameFutureBuilder(
                                    groupIds[index]), // Display group names
                                trailing: const Wrap(
                                  spacing: 12,
                                  children: [
                                    Text(
                                      'RM150',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Icon(CupertinoIcons.forward),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 90.0),
        ],
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
      var groupIds = List<String>.from(snapshot.data()?['groups'] ?? []);
      return groupIds;
    }).asyncMap((groupIds) async {
      return groupIds;
    });
  } else {
    yield [];
  }
}

FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>
    buildGroupNameFutureBuilder(String groupId) {
  return FutureBuilder(
    future: FirebaseFirestore.instance.collection('groups').doc(groupId).get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox.shrink();
      } else {
        var groupName = snapshot.data?['groupname'];
        return Text(groupName);
      }
    },
  );
}
