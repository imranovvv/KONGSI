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
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  TextEditingController groupNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController textController = TextEditingController();
  TextEditingController selectedValueController = TextEditingController();

  final List<String> items = [];

  void addMember(String name) {
    setState(() {
      items.add(name);
      textController.clear();
    });
  }

  void removeMember(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  Future fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String currentUserDisplayName = userDoc.get('name');

          setState(() {
            items.insert(0, currentUserDisplayName);
          });
        }
      } else {
        String currentUserDisplayName = 'Guest';
        setState(() {
          items.insert(0, currentUserDisplayName);
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void addGroup() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    try {
      Map<String, dynamic> membersMap = {};
      for (var i = 0; i < items.length; i++) {
        if (i == 0) {
          membersMap[items[i]] = user?.uid ?? '';
        } else {
          membersMap[items[i]] = '';
        }
      }

      DocumentReference groupRef = await firestore.collection('groups').add({
        'groupname': groupNameController.text,
        'description': descriptionController.text,
        'currency': selectedValueController.text,
        'members': membersMap,
      });

      // Step 2: Get the generated groupId
      String groupId = groupRef.id;

      // Step 3: Update 'groups' map in 'users' collection for each member
      for (String memberName in items) {
        // Retrieve the user document based on the user name
        QuerySnapshot userSnapshot = await firestore
            .collection('users')
            .where('name', isEqualTo: memberName)
            .get();

        // Check if the user exists (this assumes name is unique in 'users' collection)
        if (userSnapshot.docs.isNotEmpty) {
          // Get the user ID
          String userId = userSnapshot.docs.first.id;

          // Create a map with the new group information
          Map<String, dynamic> newGroup = {
            groupNameController.text: groupId,
          };

          // Get the current 'groups' map of the user
          Map<String, dynamic>? currentGroups =
              userSnapshot.docs.first['groups'];

          // Merge the new group information with the current 'groups' map
          currentGroups?.addAll(newGroup);

          // Update 'groups' map in the user's document
          await firestore.collection('users').doc(userId).update({
            'groups': currentGroups,
          });
        } else {
          print('User with name $memberName not found.');
          // Handle the case where the user is not found in the 'users' collection
        }
      }

      print('Group added to Firestore successfully!');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      print('Error adding group to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(showLogoutButton: false),
      body: Column(
        children: [
          AppBar(
            centerTitle: true,
            title: const Text(
              'New Group',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
              child: Column(
                children: [
                  CupertinoTextField(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey, // You can set the shadow color
                          offset:
                              Offset(0, 1), // Specify the offset of the shadow
                          blurRadius: 4, // Specify the blur radius
                        ),
                      ],
                    ),
                    placeholder: 'Title',
                    controller: groupNameController,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.poppins(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                  const SizedBox(height: 20.0),
                  CupertinoTextField(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey, // You can set the shadow color
                          offset:
                              Offset(0, 1), // Specify the offset of the shadow
                          blurRadius: 4, // Specify the blur radius
                        ),
                      ],
                    ),
                    placeholder: 'Description',
                    controller: descriptionController,
                    keyboardType: TextInputType.text,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    clearButtonMode: OverlayVisibilityMode.editing,
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey, // You can set the shadow color
                          offset:
                              Offset(0, 1), // Specify the offset of the shadow
                          blurRadius: 4, // Specify the blur radius
                        ),
                      ],
                    ),
                    child: DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        constraints: const BoxConstraints.tightFor(
                          height: 300,
                        ),
                        showSearchBox: true,
                        searchDelay: Duration.zero,
                        showSelectedItems: true,
                        containerBuilder: (ctx, popupWidget) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: popupWidget,
                          );
                        },
                      ),
                      items: const [
                        "MYR",
                        "USD",
                        "EUR",
                      ],
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: "Select currency",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 16, top: 3),
                        ),
                      ),
                      onChanged: (selectedItem) {
                        setState(() {
                          selectedValueController.text = selectedItem!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CupertinoScrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length + 1,
                          itemBuilder: (context, index) {
                            if (index < items.length) {
                              return ListTile(
                                contentPadding:
                                    const EdgeInsets.only(left: 20.0),
                                title: Text(items[index]),
                                trailing: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    removeMember(index);
                                  },
                                ),
                              );
                            } else {
                              return ListTile(
                                contentPadding:
                                    const EdgeInsets.only(left: 20.0),
                                title: TextField(
                                  controller: textController,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Enter name', // Add hint text here
                                  ),
                                  // decoration: BoxDecoration(
                                  //   borderRadius: BorderRadius.circular(30.0),
                                  //   color: Colors.white,
                                  // ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    addMember(textController.text);
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff10416d),
                        elevation: 0,
                      ),
                      onPressed: () {
                        addGroup();
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget _customPopupItemBuilder(
//     BuildContext context, dynamic item, bool isSelected) {
//   return Container(
//     margin: const EdgeInsets.symmetric(horizontal: 8),
//     decoration: !isSelected
//         ? null
//         : BoxDecoration(
//             border: Border.all(color: Theme.of(context).primaryColor),
//             borderRadius: BorderRadius.circular(5),
//             color: Colors.white,
//           ),
//     child: ListTile(
//       title: Text(item.toString(),
//           style: const TextStyle(
//             fontSize: 14,
//             color: Color.fromARGB(255, 102, 100, 100),
//           )),
//     ),
//   );
// }
