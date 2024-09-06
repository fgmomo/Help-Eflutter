// lib/models/ticket_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;
  final String titre;
  final String description;
  final String categorieId;
  final String prioriteId;
  final String status;
  final DateTime dateCreation;

  Ticket({
    required this.id,
    required this.titre,
    required this.description,
    required this.categorieId,
    required this.prioriteId,
    required this.status,
    required this.dateCreation,
  });

  factory Ticket.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
  
    return Ticket(
      id: doc.id,
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      prioriteId: data['prioriteId'] ?? '',
      categorieId: data['categorieId'] ?? '',
      status: data['status'] ?? '',
      dateCreation: (data['date_creation'] as Timestamp).toDate(),
    );
  }
}


