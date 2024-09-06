import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/config/config.dart';
import 'package:flutterapp/screens/views/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? prenom;
  String? nom;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            prenom = userDoc['prenom'];
            nom = userDoc['nom'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
      // Gérer les erreurs de récupération des données
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      // Gérer les erreurs de déconnexion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondLegerColor, // Remplacez par votre couleur secondaire claire
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20), // Espace en haut
            Center(
              child: Icon(
                Icons.person,
                size: 100,
                color: Colors.blueGrey, // Remplacez par la couleur souhaitée
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Text(
                        '$prenom $nom',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          color: const Color.fromARGB(255, 255, 255, 255), // Couleur de fond blanche pour la carte
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mon compte',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                              ListTile(
                                  leading: Icon(Icons.person),
                                  title: Text('Profil'),
                                  onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(),
                            ),
                          );

                          // Rafraîchir les données si le profil a été mis à jour
                          if (result == true) {
                            _loadUserData();
                          }
                        },
                      ),
                                Divider(), // Ligne fine séparant les éléments
                                ListTile(
                                  leading: Icon(Icons.notifications),
                                  title: Text('Notifications'),
                                  onTap: () {
                                    // Action pour naviguer vers la page de notifications
                                  },
                                ),
                                Divider(), // Ligne fine séparant les éléments
                                ListTile(
                                  leading: Icon(Icons.logout),
                                  title: Text('Déconnexion'),
                                  onTap: () async {
                                    await _logout();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
