import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kongsi/screens/home.dart';
import 'package:kongsi/screens/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kongsi/screens/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
              ), // Adjust the padding as needed
              child: Image.asset(
                'images/LogoKongsi.png',
                height: 40, // You can adjust the height as needed
              ),
            )),
        body: const Register(),
        // bottomNavigationBar: BottomAppBar(
        //   color: const Color(0xFFFBFBFB),
        //   child: Row(
        //     mainAxisSize: MainAxisSize.max,
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     children: [
        //       IconButton(
        //         icon: const Icon(CupertinoIcons.house_fill),
        //         onPressed: () {},
        //       ),
        //       IconButton(
        //         icon: const Icon(CupertinoIcons.gear_alt_fill),
        //         onPressed: () {},
        //       ),
        //     ],
        //   ),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: ClipPath(
        //   clipper: DiamondClipper(),
        //   child: FloatingActionButton(
        //     backgroundColor: const Color(0xff10416d),
        //     elevation: 0,
        //     onPressed: () {
        //       // ignore: avoid_print
        //       print("Button is pressed.");
        //     },
        //     child: const Icon(Icons.add),
        //   ),
        // ),
      ),
    );
  }
}

class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
