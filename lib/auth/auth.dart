import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kongsi/screens/home.dart';
import 'package:kongsi/screens/login.dart';
import 'package:kongsi/screens/register.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const Home();
          } else {
            if (showLoginPage) {
              return Login(
                onTap: togglePages,
              );
            } else {
              return Register(
                onTap: togglePages,
              );
            }
          }
        },
      ),
    );
  }
}
