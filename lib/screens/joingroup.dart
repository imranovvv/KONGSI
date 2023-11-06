import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kongsi/components/appbar.dart';

class JoinGroup extends StatefulWidget {
  const JoinGroup({super.key});

  @override
  State<JoinGroup> createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
  List<String> items = [];
  TextEditingController groupNameController = TextEditingController();

  void addMember(String name) {
    setState(() {
      items.add(name);
    });
  }

  void removeMember(int index) {
    setState(() {
      items.removeAt(index);
    });
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
              title: const Text(
                'Join Group',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                child: CupertinoTextField(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
