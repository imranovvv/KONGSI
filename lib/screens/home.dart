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
  const Home({Key? key});

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
    await FirebaseAuth.instance.signOut();
  }

  List<String> userGroupNames = [];

  Stream<Map<String, dynamic>> stream = getUserGroupsMapStream();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          StreamBuilder<Map<String, dynamic>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CupertinoActivityIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                var groupsMap =
                    snapshot.data?['groups'] as Map<String, dynamic>? ?? {};
                var groupNames = groupsMap.keys.toList();
                var groupIds = groupsMap.values.cast<String>().toList();

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CupertinoScrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: groupNames.length,
                        itemBuilder: (context, index) {
                          Color tileColor = index.isOdd
                              ? const Color(0xffECECEC)
                              : Colors.white;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => GroupDetailPage(
                                    groupName: groupNames[index],
                                    groupId: groupIds[index],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                tileColor: tileColor,
                                title: Text(groupNames[index]),
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

Stream<Map<String, dynamic>> getUserGroupsMapStream() async* {
  User? user = FirebaseAuth.instance.currentUser;
  String? userId = user?.uid;
  if (userId != null) {
    var userDocument =
        FirebaseFirestore.instance.collection('users').doc(userId);
    yield* userDocument.snapshots().map((snapshot) {
      var groupsMap =
          Map<String, dynamic>.from(snapshot.data()?['groups'] ?? {});
      return {'groups': groupsMap};
    });
  } else {
    yield {'groups': {}};
  }
}
