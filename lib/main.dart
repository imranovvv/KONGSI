import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kongsi/auth/auth.dart';
import 'package:kongsi/screens/home.dart';
import 'package:kongsi/screens/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kongsi/screens/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void signOut() async {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => const Login(),
        '/home': (context) => const Home(),
        '/register': (context) => const Register(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE8EEF3),
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        scaffoldBackgroundColor: const Color(0xFFE8EEF3),
        textTheme: GoogleFonts.poppinsTextTheme(),
        // cupertinoOverrideTheme:
        //     CupertinoThemeData(brightness: Brightness.light),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          titleSpacing: 10,
          centerTitle: false,
          title: const Text(
            'Kongsi',
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(
              left: 16,
            ),
            child: Image.asset(
              'images/LogoKongsi.png',
              height: 40,
            ),
          ),
          actions: [
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: 0,
                    child: Text(
                        'Logout'), // Add a value to identify the Logout menu item.
                  ),
                  const PopupMenuItem(
                    value: 1,
                    child: Text('Item 2'),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text('Item 3'),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  signOut();
                }
              },
            ),
          ],
        ),
        body: const Auth(),
      ),
    );
  }
}
