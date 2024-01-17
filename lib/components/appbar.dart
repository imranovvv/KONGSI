import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showLogoutButton;
  final bool showDoneButton;

  const CustomAppBar(
      {super.key,
      required this.showLogoutButton,
      required this.showDoneButton});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  void signOut() async {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
        if (showLogoutButton)
          // PopupMenuButton(
          //   itemBuilder: (BuildContext context) {
          //     return [
          //       const PopupMenuItem(
          //         value: 0,
          //         child: Text('Logout'),
          //       ),
          //     ];
          //   },
          //   onSelected: (value) {
          //     if (value == 0) {
          //       signOut();
          //     }
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              signOut();
            },
          ),
        if (showDoneButton)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
      ],
    );
  }
}
