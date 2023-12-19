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

class _HomeState extends State<Home> {
  final TextEditingController searchController = TextEditingController();
  String? searchQuery;
  final Stream<Map<String, dynamic>> _stream = _getUserGroupsMapStream();
  bool isSelected = true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
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
        title: const Text('My Groups',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildBalanceRow(),
          _buildSearchBar(),
          _buildGroupsList(),
          const SizedBox(height: 90.0),
        ],
      ),
      floatingActionButton: _buildSpeedDial(),
    );
  }

  Widget _buildBalanceRow() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Balance: ', style: TextStyle(fontSize: 16)),
        Text('RM150', style: TextStyle(fontSize: 16, color: Colors.green)),
      ],
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

  Widget _buildGroupTile(String groupName, String groupId, int index) {
    Color tileColor = index.isOdd ? const Color(0xffECECEC) : Colors.white;
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) =>
                  GroupDetailPage(groupName: groupName, groupId: groupId))),
      child: Card(
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          tileColor: tileColor,
          title: Text(groupName),
          trailing: const Wrap(
            spacing: 12,
            children: [
              Text('RM150',
                  style: TextStyle(fontSize: 16, color: Colors.green)),
              Icon(CupertinoIcons.forward),
            ],
          ),
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
          onTap: () => Navigator.push(context,
              CupertinoPageRoute(builder: (context) => const NewGroup())),
        ),
        SpeedDialChild(
          child: const Icon(CupertinoIcons.person_2_fill),
          label: 'Join Group',
          onTap: () => Navigator.push(context,
              CupertinoPageRoute(builder: (context) => const JoinGroup())),
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

  static Stream<Map<String, dynamic>> _getUserGroupsMapStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value({'groups': {}});

    var userDocument =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    return userDocument.snapshots().map((snapshot) => {
          'groups': Map<String, dynamic>.from(snapshot.data()?['groups'] ?? {})
        });
  }
}
