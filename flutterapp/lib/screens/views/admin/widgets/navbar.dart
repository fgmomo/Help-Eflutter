import 'package:flutter/material.dart';

class AdminNavbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Image.asset(
              'assets/img/logo.png',
              height: 40,
              
              
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Icon(Icons.menu), 
          ),
        ],
      ),
      leadingWidth: 120,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              'Admin connecté',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
      titleSpacing: 0,
      elevation: 8.0, // Ajout de l'ombre au navbar
      shadowColor: Colors.black.withOpacity(0.5), 
      backgroundColor: Colors.white, 
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
