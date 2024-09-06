import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  String _selectedRole = 'admin'; // Valeur initiale pour le DropdownButton lors de l'ajout d'un utilisateur

  @override
   Widget build(BuildContext context) {
    // Référence à la collection 'users' dans Firestore
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Liste des Utilisateurs',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showAddUserDialog(context);
                  },
                  child: Text('Ajouter Utilisateur'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: users.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Une erreur s'est produite : ${snapshot.error}");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Mappez les documents Firestore en lignes de tableau
                  final List<DataRow> rows = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id; // Obtenez l'ID du document pour la suppression et la modification
                    return DataRow(
                      cells: [
                        DataCell(Text(data['nom'] ?? '')),
                        DataCell(Text(data['prenom'] ?? '')),
                        DataCell(Text(data['email'] ?? '')),
                        DataCell(Text(data['telephone'] ?? '')),
                        DataCell(Text(data['role'] ?? '')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _showEditUserDialog(context, docId, data);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(context, docId);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade100),
                      columns: [
                        DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Prénom', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Téléphone', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Rôle', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: rows,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

   void _showAddUserDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nomController = TextEditingController();
    final TextEditingController _prenomController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _telephoneController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController(); // Nouveau champ de mot de passe

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un Utilisateur'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(labelText: 'Nom'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _prenomController,
                  decoration: InputDecoration(labelText: 'Prénom'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prénom';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _telephoneController,
                  decoration: InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: _passwordController, // Nouveau champ de mot de passe
                  decoration: InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true, // Cache le mot de passe
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit comporter au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Rôle'),
                  items: <String>['admin', 'apprenant', 'formateur']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addUser(
                    _nomController.text,
                    _prenomController.text,
                    _emailController.text,
                    _telephoneController.text,
                    _passwordController.text, // Ajouter le mot de passe
                    _selectedRole, // Utiliser la valeur sélectionnée du DropdownButton
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

 Future<void> _addUser(
    String nom,
    String prenom,
    String email,
    String telephone,
    String password,
    String role) async {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  try {
    // Création de l'utilisateur avec Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Obtenez l'ID de l'utilisateur créé
    String uid = userCredential.user!.uid;

    // Ajout des informations supplémentaires dans Firestore
    await users.doc(uid).set({
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'role': role,
    });

    print('Utilisateur ajouté avec succès.');
  } catch (e) {
    print('Erreur lors de l\'ajout de l\'utilisateur : $e');
  }
}

  void _showEditUserDialog(BuildContext context, String docId, Map<String, dynamic> userData) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nomController = TextEditingController(text: userData['nom']);
    final TextEditingController _prenomController = TextEditingController(text: userData['prenom']);
    final TextEditingController _emailController = TextEditingController(text: userData['email']);
    final TextEditingController _telephoneController = TextEditingController(text: userData['telephone']);
    String _role = userData['role'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier l\'Utilisateur'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(labelText: 'Nom'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _prenomController,
                  decoration: InputDecoration(labelText: 'Prénom'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prénom';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _telephoneController,
                  decoration: InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _role,
                  onChanged: (String? newValue) {
                    setState(() {
                      _role = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Rôle'),
                  items: <String>['admin', 'apprenant', 'formateur']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateUser(
                    docId,
                    _nomController.text,
                    _prenomController.text,
                    _emailController.text,
                    _telephoneController.text,
                    _role,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUser(String docId, String nom, String prenom, String email, String telephone, String role) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      await users.doc(docId).update({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'role': role,
      });
    } catch (e) {
      print('Erreur lors de la modification de l\'utilisateur : $e');
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Supprimer l\'Utilisateur'),
          content: Text('Êtes-vous sûr de vouloir supprimer cet utilisateur ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteUser(docId);
                Navigator.of(context).pop();
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(String docId) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      await users.doc(docId).delete();
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur : $e');
    }
  }
}
