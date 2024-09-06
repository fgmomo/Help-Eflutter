import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String titre;
  final String description;
  final String categorieId;
  final String prioriteId;
  final String status;
  final DateTime dateCreation;

  Ticket({
    required this.titre,
    required this.description,
    required this.categorieId,
    required this.prioriteId,
    required this.status,
    required this.dateCreation,
  });

  factory Ticket.fromDocumentSnapshot(DocumentSnapshot doc) {
    return Ticket(
      titre: doc['titre'],
      description: doc['description'],
      categorieId: doc['categorieId'],
      prioriteId: doc['prioriteId'],
      status: doc['status'],
      dateCreation: (doc['date_creation'] as Timestamp).toDate(),
    );
  }
}
