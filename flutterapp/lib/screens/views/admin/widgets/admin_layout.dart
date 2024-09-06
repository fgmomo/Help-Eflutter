import 'package:flutter/material.dart';
import 'package:flutterapp/screens/views/admin/widgets/sidebar.dart';
import 'package:flutterapp/screens/views/admin/widgets/navbar.dart';

class AdminLayout extends StatelessWidget {
  final Widget page; // Le paramètre pour la page à afficher

  const AdminLayout({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminNavbar(),  // Navbar fixe en haut
      drawer: AdminSidebar(onItemTapped: (index) {
        // Ajoutez la logique de navigation ici
      }),
      body: Row(
        children: [
          // Sidebar fixe à gauche
          SizedBox(
            width: 250,
            child: AdminSidebar(onItemTapped: (index) {
              // Ajoutez la logique de navigation ici
            }),
          ),
          // Contenu principal qui change en fonction de la sélection
          Expanded(
            child: page,  // La page passée en paramètre
          ),
        ],
      ),
    );
  }
}
