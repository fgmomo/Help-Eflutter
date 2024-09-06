import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutterapp/config/config.dart';
import 'package:flutterapp/screens/home_screen.dart';
import 'package:flutterapp/screens/views/admin/dashboard.dart';
import 'package:flutterapp/screens/views/formateur/formateur__layout.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                'Connectez-vous',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                ),
              ),
              SizedBox(height: 16), // Espace entre le titre et le texte
              Text(
                'Bienvenue ! Veuillez entrer vos informations pour accéder à votre espace.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: fontFamily,
                ),
              ),
              SizedBox(height: 32), // Espace avant les champs de texte
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();
                    _login(context, email, password);
                  },
                  child: Text('Connexion'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primColor, // Couleur de fond du bouton
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Bord arrondi
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Action pour "Mot de passe oublié ?"
                },
                child: Text(
                  'Mot de passe oublié ?',
                  style: TextStyle(
                    color: primColor,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Future<void> _login(BuildContext context, String email, String password) async {
  try {
    // Connexion de l'utilisateur avec Firebase
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Récupération de l'ID de l'utilisateur
    String uid = userCredential.user!.uid;

    // Récupération des données utilisateur depuis Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      String role = userDoc['role']; // Récupérer le rôle de l'utilisateur

      // Navigation vers la page appropriée en fonction du rôle
      if (role == 'apprenant') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } 
      else if (role == 'formateur') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FormateurHomeScreen()),
        );
      } 
      else if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } 
      // FormateurHomeScreen
      else {
        // Gérer les cas où le rôle n'est pas reconnu
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rôle non reconnu.')));
      }
    } else {
      // le cas où le document utilisateur n'existe pas
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilisateur non trouvé.')));
    }
  } catch (e) {
    String message;
    if (e is FirebaseAuthException) {
      // Gestion des erreurs Firebase spécifiques
      print('Erreur de connexion Firebase: ${e.code}');
      switch (e.code) {
        case 'invalid-email':
          message = 'L\'adresse email est invalide.';
          break;
        case 'wrong-password':
          message = 'Le mot de passe est incorrect.';
          break;
        default:
          message = 'Une erreur est survenue lors de la connexion. Veuillez réessayer.';
          break;
      }
    } else {
      // Gestion des autres types d'erreurs
      print('Erreur de connexion: $e');
      message = 'Une erreur est survenue lors de la connexion. Merci de réessayer.';
    }
    // Afficher le message d'erreur (par exemple, en utilisant un Snackbar)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

}
