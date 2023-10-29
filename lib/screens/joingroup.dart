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
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showLogoutButton: false),
      body: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppBar(
                title: const Text(
                  'Join Group',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CupertinoTextField(
                placeholder: 'Name',
                controller: nameController,
                keyboardType: TextInputType.text,
                padding: const EdgeInsets.all(10.0),
                clearButtonMode: OverlayVisibilityMode.editing,
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                placeholder: 'Email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                padding: const EdgeInsets.all(10.0),
                clearButtonMode: OverlayVisibilityMode.editing,
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ],
      ),
    );
  }
}
