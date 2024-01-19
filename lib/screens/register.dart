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
  bool isEmptyName = false;
  bool isEmptyEmail = false;
  bool isInvalidEmail = false;
  bool isEmptyPassword = false;
  bool isEmptyConfirmPassword = false;
  bool isPasswordMismatch = false;
  bool isWeakPassword = false;

  void signUp() async {
    setState(() {
      isEmptyName = nameController.text.isEmpty;
      isEmptyEmail = emailController.text.isEmpty;
      isInvalidEmail = false;
      isEmptyPassword = passwordController.text.isEmpty;
      isEmptyConfirmPassword = confirmPasswordController.text.isEmpty;
      isPasswordMismatch =
          passwordController.text != confirmPasswordController.text;
      isWeakPassword = false;
    });

    if (isEmptyName ||
        isEmptyEmail ||
        isInvalidEmail ||
        isEmptyPassword ||
        isEmptyConfirmPassword ||
        isPasswordMismatch) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(child: CupertinoActivityIndicator()),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      addUser(nameController.text, emailController.text);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      if (e.code == 'invalid-email') {
        setState(() => isInvalidEmail = true);
      }
      if (e.code == 'weak-password') {
        setState(() => isWeakPassword = true);
      }
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
                    const SizedBox(height: 8.0),
                    if (isEmptyName)
                      const Text('Name cannot be empty',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                    const SizedBox(height: 16.0),
                    CupertinoTextField(
                      placeholder: 'Email',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      padding: const EdgeInsets.all(10.0),
                      clearButtonMode: OverlayVisibilityMode.editing,
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 8.0),
                    if (isEmptyEmail)
                      const Text('Email cannot be empty',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                    if (isInvalidEmail)
                      const Text('Invalid email format',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
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
                    const SizedBox(height: 8.0),
                    if (isEmptyPassword)
                      const Text('Password cannot be empty',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
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
                    const SizedBox(height: 8.0),
                    if (isEmptyConfirmPassword)
                      const Text('Confirm Password cannot be empty',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                    if (isPasswordMismatch)
                      const Text('Passwords do not match',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                    if (isWeakPassword)
                      const Text('Passwords must be more than 6 characters',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
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
