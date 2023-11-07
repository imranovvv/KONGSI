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
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(showLogoutButton: false),
      body: Stack(
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
          Positioned(
            top: MediaQuery.of(context).size.height / 3,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  placeholder: 'Paste the invitation link',
                  controller: groupNameController,
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.poppins(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.link),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.width * 0.1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff10416d),
                  elevation: 0,
                ),
                onPressed: () {},
                child: const Text(
                  "Join",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
