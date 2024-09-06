import 'package:flutter/material.dart';

 

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
         
          Expanded(
            child: Center(
              child: Text('Bienvenue sur le Dashboard Admin'),
            ),
          ),
        ],
      ),
    );
  }
}
