import 'package:flutter/material.dart';
import 'package:kongsi/auth/auth.dart';
import 'package:kongsi/screens/home.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: MaterialApp(
        routes: {
          '/home': (context) => const Home(),
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
        ),
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Auth(),
        ),
      ),
    );
  }
}
