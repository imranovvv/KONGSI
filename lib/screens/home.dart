import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController searchController = TextEditingController();
  List<String> groupNames = ["Family 👪", "Housemates", "Travel", "Tests"];
  List<String> filteredGroupNames = [];

  @override
  void initState() {
    super.initState();
    filteredGroupNames.addAll(groupNames);
  }

  void filterGroups(String query) {
    setState(() {
      filteredGroupNames = groupNames
          .where((groupName) =>
              groupName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void signOut() async {
    Navigator.of(context).pop();

    FirebaseAuth.instance.signOut();
  }

  bool isSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SpeedDial(
        backgroundColor: const Color(0xff10416d),
        children: [
          SpeedDialChild(
              child: const Icon(CupertinoIcons.person_add_solid),
              label: 'New Group'),
          SpeedDialChild(
              child: const Icon(CupertinoIcons.person_2_fill),
              label: 'Join Group'),
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

      body: Align(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
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
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 16, bottom: 16),
              child: Center(
                child: CupertinoSearchTextField(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.white,
                  ),
                  controller: searchController,
                  onChanged: filterGroups,
                  style: GoogleFonts.poppins(),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CupertinoScrollbar(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: filteredGroupNames.length,
                    itemBuilder: (context, index) {
                      Color tileColor =
                          index.isOdd ? const Color(0xffECECEC) : Colors.white;

                      return Card(
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          tileColor: tileColor,
                          title: Text(filteredGroupNames[index]),
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
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
