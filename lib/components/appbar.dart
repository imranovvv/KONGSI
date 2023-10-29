import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showLogoutButton; // Boolean parameter

  const CustomAppBar({super.key, required this.showLogoutButton});

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
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 0,
                  child: Text('Logout'),
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
    );
  }
}
