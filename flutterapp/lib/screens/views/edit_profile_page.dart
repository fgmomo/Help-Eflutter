import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/config/config.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _prenomController.text = userDoc['prenom'] ?? '';
            _nomController.text = userDoc['nom'] ?? '';
            _emailController.text = userDoc['email'] ?? '';
            _telephoneController.text = userDoc['telephone'] ?? '';
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Erreur lors du chargement des données utilisateur');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Mise à jour dans Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'prenom': _prenomController.text,
          'nom': _nomController.text,
          'email': _emailController.text,
          'telephone': _telephoneController.text,
        });

        // Mise à jour de l'email dans FirebaseAuth si nécessaire
        if (user.email != _emailController.text) {
          await user.updateEmail(_emailController.text);
          await user.reload(); // Recharger l'utilisateur
          user = FirebaseAuth.instance.currentUser;
        }

        // Mise à jour du mot de passe si les champs sont remplis
        if (_currentPasswordController.text.isNotEmpty &&
            _newPasswordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty) {

          // Vérifiez que les nouveaux mots de passe correspondent
          if (_newPasswordController.text != _confirmPasswordController.text) {
            _showErrorDialog('Les nouveaux mots de passe ne correspondent pas.');
            return;
          }

          // Authentifiez l'utilisateur avec le mot de passe actuel
          AuthCredential credential = EmailAuthProvider.credential(
            email: user?.email ?? '',
            password: _currentPasswordController.text,
          );

          try {
            await user?.reauthenticateWithCredential??(credential);

            // Mise à jour du mot de passe
            await user?.updatePassword(_newPasswordController.text);

          } catch (e) {
            _showErrorDialog('Mot de passe actuel incorrect ou erreur lors de la mise à jour.');
            return;
          }
        }

        _showSuccessDialog('Profil mis à jour avec succès');
      } else {
        _showErrorDialog('Utilisateur non authentifié.');
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de la mise à jour du profil: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Succès'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Indique que les données ont été mises à jour
            },
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondLegerColor, // Couleur de fond
      appBar: AppBar(
        title: Text('Éditer le Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextField(
                    controller: _prenomController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _telephoneController,
                    decoration: InputDecoration(
                      labelText: 'Téléphone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de Passe Actuel',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Nouveau Mot de Passe',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmer Nouveau Mot de Passe',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: Text('Enregistrer'),
                  ),
                ],
              ),
      ),
    );
  }
}
