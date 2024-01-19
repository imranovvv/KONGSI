import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kongsi/screens/groupdetailpage.dart';
import 'package:kongsi/screens/joingroup.dart';
import 'package:kongsi/screens/newgroup.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class Expense {
  final String title;
  final double amount;
  final String paidBy;
  final DateTime date;
  final Map<String, double> debtors;

  Expense({
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.date,
    required this.debtors,
  });
}

class _HomeState extends State<Home> {
  final TextEditingController searchController = TextEditingController();
  String? searchQuery;
  late Stream<Map<String, dynamic>> _stream;
  bool isSelected = true;
  String? userName;

  @override
  void initState() {
    super.initState();
    _stream = _getUserGroupsMapStream();
    _fetchUserName();

    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDocument =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      userDocument.get().then((snapshot) {
        if (snapshot.exists) {
          var userData = snapshot.data() as Map<String, dynamic>;
          setState(() {
            userName = userData['name'];
          });
        }
      }).catchError((error) {});
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '${userName ?? ""}\'s Groups',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildGroupsList(),
          const SizedBox(height: 90.0),
        ],
      ),
      floatingActionButton: _buildSpeedDial(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: CupertinoSearchTextField(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.white,
        ),
        controller: searchController,
        style: GoogleFonts.poppins(),
      ),
    );
  }

  Widget _buildGroupsList() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _stream,
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoActivityIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Map<String, dynamic> groupsMap =
              snapshot.data!['groups'] as Map<String, dynamic>;
          if (groupsMap.isEmpty) {
            return const Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "You don't have any groups yet. Click the \"+\" button to add or join a group.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          List<String> groupNames = groupsMap.keys.toList();
          List groupIds = groupsMap.values.map((e) => e['id']).toList();

          if (searchQuery != null && searchQuery!.isNotEmpty) {
            groupNames = groupNames
                .where((name) => name.toLowerCase().contains(searchQuery!))
                .toList();
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoScrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  itemCount: groupNames.length,
                  itemBuilder: (context, index) => _buildGroupTile(
                      groupNames[index], groupIds[index], index),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  final DecorationTween _tween = DecorationTween(
    begin: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
    ),
    end: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      boxShadow: CupertinoContextMenu.kEndBoxShadow,
    ),
  );

  Animation<Decoration> _boxDecorationAnimation(Animation<double> animation) {
    return _tween.animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          0.0,
          CupertinoContextMenu.animationOpensAt,
        ),
      ),
    );
  }

  Widget _buildGroupTile(String groupName, String groupId, int index) {
    Color tileColor = index.isOdd ? const Color(0xffECECEC) : Colors.white;

    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 100,
              color: Colors.white,
              child: Center(
                child: ListTile(
                  leading: const Icon(CupertinoIcons.delete, color: Colors.red),
                  title: const Text('Delete'),
                  onTap: () {
                    _deleteGroup(groupName);
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
        );
      },
      child: Card(
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          tileColor: tileColor,
          title: Text(groupName),
          trailing: const Icon(CupertinoIcons.forward),
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => GroupDetailPage(
                  groupId: groupId,
                  groupName: groupName,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      backgroundColor: const Color(0xff10416d),
      children: [
        SpeedDialChild(
          child: const Icon(CupertinoIcons.person_add_solid),
          label: 'New Group',
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const NewGroup()),
          ),
        ),
        SpeedDialChild(
          child: const Icon(CupertinoIcons.person_2_fill),
          label: 'Join Group',
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const JoinGroup()),
          ),
        ),
      ],
      onOpen: () => setState(() => isSelected = !isSelected),
      onClose: () => setState(() => isSelected = !isSelected),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: isSelected
            ? const Icon(Icons.add, key: Key('addIcon'))
            : const Icon(Icons.clear, key: Key('clearIcon')),
      ),
    );
  }

  Future<void> _deleteGroup(String groupName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentReference userDocument =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDocument.update({
          'groups.$groupName': FieldValue.delete(),
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Stream<Map<String, dynamic>> _getUserGroupsMapStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value({'groups': {}});

    DocumentReference userDocument =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    return userDocument.snapshots().map((DocumentSnapshot snapshot) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return {'groups': {}};

      Map<String, dynamic> groupsMap =
          Map<String, dynamic>.from(data['groups'] ?? {});
      List<MapEntry<String, dynamic>> sortedGroups = groupsMap.entries.toList()
        ..sort((b, a) => (a.value['createdAt'] as Timestamp)
            .compareTo(b.value['createdAt'] as Timestamp));

      Map<String, dynamic> orderedGroups = {
        for (var entry in sortedGroups) entry.key: entry.value
      };

      return {'groups': orderedGroups};
    });
  }
}
