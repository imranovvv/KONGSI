import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kongsi/components/appbar.dart';
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

  void signOut() async {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const Scaffold(
            appBar: CustomAppBar(
              showLogoutButton: true,
              showDoneButton: false,
            ),
            body: Home(),
          );
        } else {
          return Scaffold(
            appBar: const CustomAppBar(
              showLogoutButton: false,
              showDoneButton: false,
            ),
            body: showLoginPage
                ? Login(
                    onTap: togglePages,
                  )
                : Register(
                    onTap: togglePages,
                  ),
          );
        }
      },
    );
  }
}
