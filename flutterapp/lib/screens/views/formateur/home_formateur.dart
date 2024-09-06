import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterapp/config/config.dart';
import 'formateur_detailTicket.dart';

class HomeFormateurView extends StatefulWidget {
  const HomeFormateurView({super.key});

  @override
  State<HomeFormateurView> createState() => _HomeFormateurViewState();
}

class _HomeFormateurViewState extends State<HomeFormateurView> {
  String selectedCategory = 'Toutes';
  String selectedPriority = 'Toutes';
  String selectedStatus = 'Tous';
  late String formateurId;
  bool isLoading = true;
  String prenom = '';
  String nom = '';
  List<String> categories = [];
  List<String> priorities = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFilterData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        formateurId = user.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            prenom = userDoc['prenom'] ?? '';
            nom = userDoc['nom'] ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  Future<void> _loadFilterData() async {
    try {
      QuerySnapshot categorySnapshot =
          await FirebaseFirestore.instance.collection('categorie').get();

      setState(() {
        categories = ['Toutes'] +
            categorySnapshot.docs
                .map((doc) => doc['libelle'] as String)
                .toList();
      });

      QuerySnapshot prioritySnapshot =
          await FirebaseFirestore.instance.collection('priorite').get();

      setState(() {
        priorities = ['Toutes'] +
            prioritySnapshot.docs
                .map((doc) => doc['libelle'] as String)
                .toList();
      });
    } catch (e) {
      print('Erreur lors du chargement des données de filtre: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            primColor, // Remplacez avec `secondLegerColor` si défini
        title: Text(
          'Accueil Formateur',
          style: TextStyle(
            color: Colors.white, // Remplacez avec `primColor` si défini
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    _buildSectionTitle('Filtrer les Tickets'),
                    SizedBox(height: 10),
                    _buildFilters(),
                    SizedBox(height: 20),
                    _buildSectionTitle('Liste des Tickets'),
                    SizedBox(height: 10),
                    _buildTicketsList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildDropdown(
            'Catégorie',
            categories,
            selectedCategory,
            (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
          ),
          SizedBox(width: 10),
          _buildDropdown(
            'Priorité',
            priorities,
            selectedPriority,
            (value) {
              setState(() {
                selectedPriority = value!;
              });
            },
          ),
          SizedBox(width: 10),
          _buildDropdown(
            'Statut',
            ['Tous', 'En attente', 'En Cours', 'Resolu'],
            selectedStatus,
            (value) {
              setState(() {
                selectedStatus = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue,
      ValueChanged<String?> onChanged) {
    return Container(
      constraints: BoxConstraints(maxWidth: 180),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildTicketsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getTicketsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucun ticket disponible.'));
        } else {
          final tickets = snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final ticketId = ticket.id;
              final status = ticket['status'] ?? '';
              final titre = ticket['titre'] ?? '';
              final description = ticket['description'] ?? '';
              final String categorieId = ticket['categorieId'] ?? '';
              final String prioriteId = ticket['prioriteId'] ?? '';

              return FutureBuilder(
                future: Future.wait([
                  fetchCategorie(categorieId),
                  fetchPriorite(prioriteId),
                ]),
                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else {
                    final categorieLibelle = snapshot.data?[0] ?? 'Inconnu';
                    final prioriteLibelle = snapshot.data?[1] ?? 'Inconnu';

                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Card(
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            titre,
                            style: TextStyle(fontFamily: 'Roboto'),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Catégorie: $categorieLibelle'),
                              Text('Priorité: $prioriteLibelle'),
                              Text('Statut: $status'),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormateurDetailticket(
                                  ticketId: ticketId,
                                  titre: titre,
                                  description: description,
                                  statut: status,
                                  categorieId: categorieId,
                                  prioriteId: prioriteId,
                                ),
                              ),
                            );
                          },
                          trailing: ElevatedButton(
                            onPressed: () =>
                                _handleTakeCharge(ticketId, status),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primColor,
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _getButtonText(status),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  String _getButtonText(String status) {
    if (status == 'En attente') {
      return 'Prendre en charge';
    } else if (status == 'En Cours') {
      return 'En cours';
    } else if (status == 'Resolu') {
      return 'Résolu';
    }
    return '';
  }

  Stream<QuerySnapshot> _getTicketsStream() {
    CollectionReference tickets =
        FirebaseFirestore.instance.collection('tickets');
    Query query = tickets;

    if (selectedCategory != 'Toutes') {
      query = query.where('categorieId',
          isEqualTo: _getCategorieId(selectedCategory));
    }

    if (selectedPriority != 'Toutes') {
      query = query.where('prioriteId',
          isEqualTo: _getPrioriteId(selectedPriority));
    }

    if (selectedStatus != 'Tous') {
      query = query.where('status', isEqualTo: selectedStatus);
    }

    return query.snapshots();
  }

  String _getCategorieId(String libelle) {
    // Ajoutez votre logique pour récupérer l'ID de la catégorie
    return '';
  }

  String _getPrioriteId(String libelle) {
    // Ajoutez votre logique pour récupérer l'ID de la priorité
    return '';
  }

  Future<String> fetchCategorie(String id) async {
    if (id.isEmpty) return 'Inconnu';

    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('categorie').doc(id).get();
    return doc.exists ? doc['libelle'] : 'Inconnu';
  }

  Future<String> fetchPriorite(String id) async {
    if (id.isEmpty) return 'Inconnu';

    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('priorite').doc(id).get();
    return doc.exists ? doc['libelle'] : 'Inconnu';
  }

  void _handleTakeCharge(String ticketId, String status) async {
    if (status == 'En attente') {
      try {
        await FirebaseFirestore.instance
            .collection('tickets')
            .doc(ticketId)
            .update({'status': 'En Cours', 'formateurId': formateurId});
      } catch (e) {
        print('Erreur lors de la prise en charge du ticket: $e');
      }
    } else {
      // Ajouter une logique pour gérer les cas où le ticket est déjà en cours ou résolu
    }
  }
}
