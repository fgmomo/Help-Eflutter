import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/ticket.dart';
import 'package:flutterapp/screens/views/detail_ticket.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Assurez-vous d'importer la page DetailTicket

class TicketsPage extends StatefulWidget {
  @override
  _TicketsPageState createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategorieId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<String> getPriorityLabel(String prioriteId) async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('priorite')
          .doc(prioriteId)
          .get();
      return doc['libelle'] ?? 'Inconnu';
    } catch (e) {
      return 'Erreur';
    }
  }

  Color _getPriorityColor(String prioriteId) {
    switch (prioriteId) {
      case 'Haute':
        return Colors.red;
      case 'Moyenne':
        return Colors.orange;
      case 'Faible':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolu':
        return Colors.green;
      case 'En cours':
        return Colors.blue;
      case 'En attente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher par titre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tickets')
                  .where('apprenant_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
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
                  final matchesQuery = ticket.titre.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesCategorie = _selectedCategorieId == null || _selectedCategorieId == 'All' || ticket.categorieId == _selectedCategorieId;
                  return matchesQuery && matchesCategorie;
                }).toList();

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
                            builder: (context) => DetailTicket(ticket: ticket,ticketSnapshot: ticketSnapshot),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      future: getPriorityLabel(ticket.prioriteId),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return const Text('Erreur');
                                        } else if (!snapshot.hasData || snapshot.data == 'Inconnu') {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Inconnu',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: _getPriorityColor(snapshot.data!),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              snapshot.data!,
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
                                      DateFormat('d MMMM yyyy').format(ticket.dateCreation),
                                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
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
    );
  }

  void _showCreateDialog() {
    // Code pour afficher le dialogue de création d'un ticket
  }
}
