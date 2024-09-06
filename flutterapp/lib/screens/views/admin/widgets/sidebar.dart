import 'package:flutter/material.dart';
import 'package:flutterapp/config/config.dart';

class AdminSidebar extends StatelessWidget {
  final Function(int) onItemTapped;

  AdminSidebar({required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(3, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildListTile(Icons.dashboard, 'Dashboard', 0),
                _buildListTile(Icons.category, 'Catégorie', 1),
                _buildListTile(Icons.priority_high, 'Priorité', 2),
                _buildListTile(Icons.support_agent, 'Tickets', 3),
                _buildListTile(Icons.people, 'Utilisateurs', 4),
                _buildListTile(Icons.logout, 'Déconnexion', 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(icon, size: 30, color: primColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontFamily: fontFamily,
          ),
        ),
        onTap: () => onItemTapped(index),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        hoverColor: secondLegerColor,
      ),
    );
  }
}
