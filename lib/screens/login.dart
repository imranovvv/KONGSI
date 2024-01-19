import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  final Function() onTap;
  const Login({super.key, required this.onTap});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isInvalidEmail = false;
  bool isEmptyEmail = false;
  bool isEmptyPassword = false;
  bool isLoginFailed = false;

  void signIn() async {
    setState(() {
      isEmptyEmail = emailController.text.isEmpty;
      isEmptyPassword = passwordController.text.isEmpty;
      isInvalidEmail = false;
      isLoginFailed = false;
    });

    if (isEmptyEmail || isEmptyPassword) return;

    showDialog(
      context: context,
      builder: (context) => const Center(child: CupertinoActivityIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      if (e.code == 'invalid-email') {
        setState(() => isInvalidEmail = true);
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        setState(() => isLoginFailed = true);
      }
    }
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.person_fill,
                        size: 80.0,
                        color: Color(0xff10416d),
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
                      const SizedBox(height: 8.0),
                      if (isEmptyEmail)
                        const Text('Enter email',
                            style: TextStyle(color: Colors.red, fontSize: 12)),
                      if (isInvalidEmail)
                        const Text('Invalid email address',
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
                        const Text('Enter password',
                            style: TextStyle(color: Colors.red, fontSize: 12)),
                      if (isLoginFailed)
                        const Text('Login failed',
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
                          onPressed: signIn,
                          child: const Text(
                            "Login",
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
                              "Don't have an account? ",
                              style: TextStyle(fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff10416d),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            CupertinoIcons.group_solid,
                            size: 50.0,
                            color: Color(0xff10416d),
                          ),
                          Icon(
                            CupertinoIcons.money_dollar_circle,
                            size: 40.0,
                            color: Color(0xff10416d),
                          ),
                          Icon(
                            CupertinoIcons.chart_pie_fill,
                            size: 40.0,
                            color: Color(0xff10416d),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
