import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterapp/config/config.dart';
import 'package:flutterapp/models/ticket.dart';
import 'package:flutterapp/screens/views/detail_ticket.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategorieId; // Stocke l'ID de la catégorie sélectionnée
  String? _selectedPrioriteId; // Stocke l'ID de la priorité sélectionnée
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/img/logoblanc.png',
          height: 40,
        ),
        backgroundColor: primColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Catégories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categorie')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var categories = snapshot.data!.docs;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((categoryDoc) {
                      String libelle = categoryDoc['libelle'];
                      String id = categoryDoc.id;
                      return _buildCategoryChip(
                          libelle, _selectedCategorieId == id, id);
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Rechercher un ticket',
                prefixIcon: Icon(Icons.search, color: primColor),
                border: OutlineInputBorder(
                  borderSide: BorderSide(strokeAlign: 2, color: primColor),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 3, horizontal: 12),
              ),
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 16),
            const Text(
              'Liste des tickets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tickets')
                    .where('apprenant_id',
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Aucun ticket trouvé.'));
                  }

                  final tickets = snapshot.data!.docs
                      .map((doc) => Ticket.fromDocumentSnapshot(doc))
                      .toList();

                  final filteredTickets = tickets.where((ticket) {
                    final matchesQuery = tickets
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());

                    final matchesCategorie = _selectedCategorieId == null ||
                        _selectedCategorieId == 'All' ||
                        ticket.categorieId == _selectedCategorieId;
                    return matchesQuery && matchesCategorie;
                  }).toList();
                  print('donnée ticket');

                  return ListView.builder(
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];

                      return InkWell(
                        onTap: () {
                          final ticketSnapshot = snapshot.data!.docs[index];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailTicket(
                                  ticket: ticket,
                                  ticketSnapshot: ticketSnapshot),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ticket.titre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        ticket.status,
                                        style: TextStyle(
                                          color: _getStatusColor(ticket.status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      FutureBuilder<String>(
                                        future: getPriorityLabel(ticket
                                            .prioriteId), // Fonction pour obtenir le libellé
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator(); // Indicateur de chargement pendant la récupération
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Erreur'); // Gérer les erreurs
                                          } else if (!snapshot.hasData ||
                                              snapshot.data == 'Inconnu') {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 8),
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .grey, // Couleur par défaut si le libellé n'est pas trouvé
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Inconnu', // Texte par défaut si le libellé est inconnu
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            );
                                          } else {
                                            // Affichage avec le libellé et la couleur associée
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 8),
                                              decoration: BoxDecoration(
                                                color: _getPriorityColor(snapshot
                                                    .data!), // Utilisation de la couleur en fonction du libellé
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                snapshot
                                                    .data!, // Affichage du libellé récupéré
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('d MMMM yyyy')
                                            .format(ticket.dateCreation),
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.red,
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 15),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Soumettre un ticket',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titreController,
                          decoration: InputDecoration(
                            labelText: 'Titre du ticket',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: primColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: primColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un titre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description du problème',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: primColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: primColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('categorie')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            var categories = snapshot.data!.docs;

                            return DropdownButtonFormField<String>(
                              value: _selectedCategorieId,
                              items: categories.map((categoryDoc) {
                                String libelle = categoryDoc['libelle'];
                                String id = categoryDoc.id;
                                return DropdownMenuItem<String>(
                                  value: id,
                                  child: Text(libelle),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategorieId = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Catégorie',
                                labelStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: primColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: primColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('priorite')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            var priorites = snapshot.data!.docs;

                            return DropdownButtonFormField<String>(
                              value: _selectedPrioriteId,
                              items: priorites.map((prioriteDoc) {
                                String libelle = prioriteDoc['libelle'];
                                String id = prioriteDoc.id;
                                return DropdownMenuItem<String>(
                                  value: id,
                                  child: Text(libelle),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPrioriteId = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Priorité',
                                labelStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: primColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: primColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await FirebaseFirestore.instance
                                  .collection('tickets')
                                  .add({
                                'titre': _titreController.text,
                                'description': _descriptionController.text,
                                'categorieId':
                                    _selectedCategorieId, // Stocke l'ID de la catégorie
                                'prioriteId':
                                    _selectedPrioriteId, // Stocke l'ID de la priorité
                                'status': 'En attente',
                                'date_creation': Timestamp.now(),
                                'apprenant_id':
                                    FirebaseAuth.instance.currentUser?.uid,
                              });

                              // Clear the form fields
                              _titreController.clear();
                              _descriptionController.clear();
                              setState(() {
                                _selectedCategorieId = null;
                                _selectedPrioriteId = null;
                              });

                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Soumettre',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: primColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategorieId = selected ? id : null;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: primColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Color _getPriorityColor(String prioriteLibelle) {
    // Personnalisation des couleurs en fonction du libellé des priorités
    switch (prioriteLibelle) {
      case 'Faible':
        return Colors.green;
      case 'Moyenne':
        return Colors.orange;
      case 'Haute':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    // Vous pouvez personnaliser les couleurs en fonction des statuts
    switch (status) {
      case 'En attente':
        return Colors.orange;
      case 'En Cours':
        return Colors.green;
      case 'Resolu':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<String> getPriorityLabel(String prioriteId) async {
    try {
      // Recherche du document dans la collection 'priorite' avec l'ID fourni
      var snapshot = await FirebaseFirestore.instance
          .collection('priorite')
          .doc(prioriteId)
          .get();

      // Si le document existe, retourne le champ 'libelle'
      if (snapshot.exists) {
        return snapshot.data()?['libelle'] ??
            'Inconnu'; // Renvoie le libellé ou 'Inconnu' si non trouvé
      } else {
        return 'Inconnu'; // Si le document n'existe pas
      }
    } catch (e) {
      print(e.toString());
      return 'Erreur'; // En cas d'erreur lors de la récupération
    }
  }
}
