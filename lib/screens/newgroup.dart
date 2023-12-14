import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kongsi/components/appbar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewGroup extends StatefulWidget {
  const NewGroup({super.key});

  @override
  State<NewGroup> createState() => _NewGroupState();
}

class _NewGroupState extends State<NewGroup> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController textController = TextEditingController();
  final TextEditingController selectedValueController = TextEditingController();

  final List<String> members = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String currentUserDisplayName = user != null
        ? (await firestore.collection('users').doc(user.uid).get()).get('name')
        : 'Guest';

    setState(() {
      members.insert(0, currentUserDisplayName);
    });
  }

  void addGroup() async {
    try {
      Map<String, String> membersMap = {
        for (var member in members)
          member: member == members.first
              ? FirebaseAuth.instance.currentUser?.uid ?? ''
              : ''
      };

      String groupId = (await firestore.collection('groups').add({
        'groupname': groupNameController.text,
        'description': descriptionController.text,
        'currency': selectedValueController.text,
        'members': membersMap,
      }))
          .id;

      await Future.forEach<String>(members, (memberName) async {
        var userSnapshot = await firestore
            .collection('users')
            .where('name', isEqualTo: memberName)
            .get();
        if (userSnapshot.docs.isNotEmpty) {
          var userId = userSnapshot.docs.first.id;
          var currentGroups = userSnapshot.docs.first.get('groups');
          await firestore.collection('users').doc(userId).update({
            'groups': {...currentGroups, groupNameController.text: groupId},
          });
        }
      });

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      print('Error adding group to Firestore: $e');
    }
  }

  Widget buildMemberList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: members.length + 1,
      itemBuilder: (context, index) {
        if (index < members.length) {
          return memberTile(index);
        } else {
          return addMemberTile();
        }
      },
    );
  }

  Widget memberTile(int index) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 20.0),
      title: Text(members[index]),
      trailing: IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => setState(() => members.removeAt(index)),
      ),
    );
  }

  Widget addMemberTile() {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 20.0),
      title: TextField(
        controller: textController,
        decoration: const InputDecoration(hintText: 'Enter name'),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          if (textController.text.isNotEmpty) {
            setState(() {
              members.add(textController.text);
              textController.clear();
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showLogoutButton: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              centerTitle: true,
              title: const Text('New Group',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                children: [
                  buildTextField(groupNameController, 'Title'),
                  const SizedBox(height: 20.0),
                  buildTextField(descriptionController, 'Description'),
                  const SizedBox(height: 20.0),
                  buildCurrencyDropdown(),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CupertinoScrollbar(child: buildMemberList()),
                  ),
                  buildSaveButton(),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String placeholder) {
    return CupertinoTextField(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.grey, offset: Offset(0, 1), blurRadius: 4)
        ],
      ),
      placeholder: placeholder,
      controller: controller,
      keyboardType: TextInputType.text,
      style: GoogleFonts.poppins(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }

  Widget buildCurrencyDropdown() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.grey, offset: Offset(0, 1), blurRadius: 4)
        ],
      ),
      child: DropdownSearch<String>(
        popupProps: PopupProps.menu(
          showSearchBox: true,
          constraints: const BoxConstraints.tightFor(height: 300),
          containerBuilder: (ctx, popupWidget) => Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
            child: popupWidget,
          ),
        ),
        items: const ["MYR", "USD", "EUR"],
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: "Select currency",
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 16, top: 3),
          ),
        ),
        onChanged: (selectedItem) =>
            selectedValueController.text = selectedItem ?? '',
      ),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.05,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: const Color(0xff10416d),
        onPressed: addGroup,
        child: const Text("Save", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
