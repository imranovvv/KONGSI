import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  final Function()? onTap;
  const Register({super.key, required this.onTap});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void signUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CupertinoActivityIndicator(),
        );
      },
    );
    try {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        addUser(nameController.text, emailController.text);
      } else {}
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      if (e.code == 'invalid-email') {}
    }
  }

  Future addUser(String name, String email) async {
    var uid = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'groups': {},
      'email': email,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.doc_person_fill,
                      size: 80.0,
                      color: Color(0xff10416d),
                    ),
                    const SizedBox(height: 16.0),
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
                    CupertinoTextField(
                      placeholder: 'Password',
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      padding: const EdgeInsets.all(10.0),
                      clearButtonMode: OverlayVisibilityMode.editing,
                      style: GoogleFonts.poppins(),
                      suffix: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            isPasswordVisible
                                ? CupertinoIcons.eye_slash_fill
                                : CupertinoIcons.eye_fill,
                            size: 24.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    CupertinoTextField(
                      placeholder: 'Confirm Password',
                      controller: confirmPasswordController,
                      obscureText: !isConfirmPasswordVisible,
                      padding: const EdgeInsets.all(10.0),
                      clearButtonMode: OverlayVisibilityMode.editing,
                      style: GoogleFonts.poppins(),
                      suffix: GestureDetector(
                        onTap: () {
                          setState(() {
                            isConfirmPasswordVisible =
                                !isConfirmPasswordVisible;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            isConfirmPasswordVisible
                                ? CupertinoIcons.eye_slash_fill
                                : CupertinoIcons.eye_fill,
                            size: 24.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 1,
                      height: MediaQuery.of(context).size.width * 0.1,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff10416d),
                          elevation: 0,
                        ),
                        onPressed: () {
                          signUp();
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff10416d),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
