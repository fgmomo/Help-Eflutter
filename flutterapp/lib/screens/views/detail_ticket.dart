import 'package:flutter/material.dart';
import 'package:flutterapp/models/ticket.dart';
import 'package:flutterapp/screens/views/formateur/discussions_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutterapp/config/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DetailTicket extends StatelessWidget {
  final DocumentSnapshot ticketSnapshot;

  const DetailTicket({Key? key, required this.ticketSnapshot, required Ticket ticket}) : super(key: key);

  Future<String> fetchCategorie(String categorieId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('categorie')
        .doc(categorieId)
        .get();
    return doc['libelle'];
  }

  Future<String> fetchPriorite(String prioriteId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('priorite')
        .doc(prioriteId)
        .get();
    return doc['libelle'];
  }

  Future<Map<String, dynamic>?> fetchReponse(String ticketId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('reponses')
        .where('ticket_id', isEqualTo: ticketId) // Utilisation de l'ID du document
        .get();
    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs.first.data() as Map<String, dynamic>?;
  }

  Future<String?> fetchFormateurName(String formateurId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(formateurId)
        .get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return '${data['prenom']} ${data['nom']}';
  }

  Future<String> _getOrCreateDiscussionId(String ticketId) async {
    // Vérifiez si une discussion existe déjà pour ce ticket
    QuerySnapshot discussionsSnapshot = await FirebaseFirestore.instance
        .collection('discussions')
        .where('ticket_id', isEqualTo: ticketId)
        .get();

    if (discussionsSnapshot.docs.isNotEmpty) {
      // Une discussion existe déjà
      return discussionsSnapshot.docs.first.id;
    } else {
      // Créez une nouvelle discussion
      DocumentReference newDiscussionRef = FirebaseFirestore.instance.collection('discussions').doc();
      await newDiscussionRef.set({'ticket_id': ticketId});
      return newDiscussionRef.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketId = ticketSnapshot.id;
    final ticketData = ticketSnapshot.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails du Ticket',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([
          fetchCategorie(ticketData['categorieId']),
          fetchPriorite(ticketData['prioriteId']),
          fetchReponse(ticketId), // Utilisation de l'ID du document pour récupérer les réponses
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            final categorieLibelle = snapshot.data![0] as String;
            final prioriteLibelle = snapshot.data![1] as String;
            final reponseData = snapshot.data![2] as Map<String, dynamic>?;

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            primColor.withOpacity(0.3),
                            primColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ticketData['titre'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    categorieLibelle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(ticketData['status']),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      ticketData['status'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(
                            height: 20,
                            thickness: 1,
                            color: Colors.black38,
                          ),
                          Text(
                            ticketData['description'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  prioriteLibelle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                'Créé le : ${DateFormat('d MMMM yyyy').format(ticketData['date_creation'].toDate())}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (reponseData != null) ...[
                            FutureBuilder<String?>(
                              future: fetchFormateurName(reponseData['formateur_id']),
                              builder: (context, formateurSnapshot) {
                                if (formateurSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (formateurSnapshot.hasError ||
                                    formateurSnapshot.data == null) {
                                  return Text(
                                      'Réponse reçue, mais erreur de chargement du formateur.');
                                } else {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Réponse : ${reponseData['reponse']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Répondu par : ${formateurSnapshot.data}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ] else ...[
                            const Text(
                              'Ce ticket n\'a pas encore été pris en charge.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              // Récupérer ou créer l'ID de la discussion
                              String discussionId = await _getOrCreateDiscussionId(ticketId);

                              // Naviguer vers l'écran de discussion
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DiscussionScreen(discussionId: discussionId),
                                ),
                              );
                            },
                            child: const Text('Commencer une discussion'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Ouvert':
        return Colors.blue;
      case 'En cours':
        return Colors.orange;
      case 'Fermé':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
