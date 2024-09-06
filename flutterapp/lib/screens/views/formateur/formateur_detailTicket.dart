import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/config/config.dart';
import 'package:flutterapp/screens/views/formateur/discussions_screen.dart';

class FormateurDetailticket extends StatefulWidget {
  final String ticketId;
  final String titre;
  final String description;
  final String statut;
  final String categorieId;
  final String prioriteId;

  const FormateurDetailticket({
    super.key,
    required this.ticketId,
    required this.titre,
    required this.description,
    required this.statut,
    required this.categorieId,
    required this.prioriteId,
  });

  @override
  State<FormateurDetailticket> createState() => _FormateurDetailticketState();
}

class _FormateurDetailticketState extends State<FormateurDetailticket> {
  TextEditingController responseController = TextEditingController();
  bool isLoading = true;
  String? formateurId;
  String? currentUserId;
  bool canRespond = false;
  String? responseText;
  bool canEditResponse = false;
  Timestamp? dateModification;

  @override
  void initState() {
    super.initState();
    _checkFormateurPermission();
  }

  Future<void> _checkFormateurPermission() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          currentUserId = user.uid;
        });

        DocumentSnapshot ticketDoc = await FirebaseFirestore.instance
            .collection('tickets')
            .doc(widget.ticketId)
            .get();

        if (ticketDoc.exists) {
          formateurId = ticketDoc['formateurId'];

          QuerySnapshot responses = await FirebaseFirestore.instance
              .collection('reponses')
              .where('ticket_id', isEqualTo: widget.ticketId)
              .where('formateur_id', isEqualTo: currentUserId)
              .get();

          setState(() {
            canRespond = formateurId == currentUserId;
            canEditResponse = responses.docs.isNotEmpty;
            responseText = responses.docs.isNotEmpty
                ? responses.docs.first['reponse']
                : null;
            dateModification = responses.docs.isNotEmpty
                ? responses.docs.first['date_modification']
                : null;
            responseController.text = responseText ?? '';
            isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Vous devez être connecté pour accéder à cette fonctionnalité.'),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      print(
          'Erreur lors de la vérification de la prise en charge du ticket: $e');
    }
  }

  Future<void> _handleResponse() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot ticketDoc = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(widget.ticketId)
          .get();
      if (ticketDoc.exists) {
        String status = ticketDoc['status'];

        QuerySnapshot responses = await FirebaseFirestore.instance
            .collection('reponses')
            .where('ticket_id', isEqualTo: widget.ticketId)
            .where('formateur_id', isEqualTo: currentUserId)
            .get();

        if (responses.docs.isNotEmpty) {
          // Mise à jour de la réponse existante
          await FirebaseFirestore.instance
              .collection('reponses')
              .doc(responses.docs.first.id)
              .update({
            'reponse': responseController.text,
            'date_modification': Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Réponse modifiée avec succès.'),
          ));
        } else {
          // Ajouter une nouvelle réponse
          await FirebaseFirestore.instance.collection('reponses').add({
            'date_reponse': Timestamp.now(),
            'formateur_id': currentUserId,
            'reponse': responseController.text,
            'ticket_id': widget.ticketId,
          });

          // Mettre à jour le ticket pour le marquer comme résolu uniquement si c'est la première réponse
          if (status != 'Resolu') {
            await FirebaseFirestore.instance
                .collection('tickets')
                .doc(widget.ticketId)
                .update({
              'status': 'Resolu',
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Réponse envoyée et ticket marqué comme résolu.'),
          ));
        }
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de la réponse: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'envoi de la réponse.'),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Ticket'),
        backgroundColor: primColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.titre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: primColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.description,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    if (responseText != null) ...[
                      Text(
                        'Réponse actuelle:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: primColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        responseText!,
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                      if (dateModification != null) ...[
                        SizedBox(height: 10),
                        Text(
                          'Dernière modification : ${dateModification!.toDate()}',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                      SizedBox(height: 20),
                    ],
                    if (canRespond || canEditResponse)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Répondre:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: primColor,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: responseController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: 'Votre réponse ici',
                              contentPadding: EdgeInsets.all(10),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          SizedBox(height: 20),
                         ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primColor,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              try {
                                // Récupérer l'id de l'apprenant à partir du ticket
                                DocumentSnapshot ticketSnapshot = await FirebaseFirestore.instance
                                    .collection('tickets')
                                    .doc(widget.ticketId)
                                    .get();

                                var apprenantId = ticketSnapshot['apprenant_id']; // ID de l'apprenant lié au ticket

                                print('Apprenant ID: $apprenantId'); // Diagnostic

                                // Vérifier si une discussion existe déjà pour ce ticket
                                QuerySnapshot discussionSnapshot = await FirebaseFirestore.instance
                                    .collection('discussions')
                                    .where('ticket_id', isEqualTo: widget.ticketId)
                                    .where('formateur_id', isEqualTo: currentUserId)
                                    .where('apprenant_id', isEqualTo: apprenantId)
                                    .get();

                                if (discussionSnapshot.docs.isEmpty) {
                                  // Créer une nouvelle discussion
                                  DocumentReference discussionRef = await FirebaseFirestore.instance
                                      .collection('discussions')
                                      .add({
                                    'ticket_id': widget.ticketId,
                                    'formateur_id': currentUserId,
                                    'apprenant_id': apprenantId,
                                    'status': 'ouverte',
                                    'created_at': Timestamp.now(),
                                  });

                                  print('Discussion créée avec ID: ${discussionRef.id}'); // Diagnostic

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Discussion créée avec succès.')),
                                  );

                                  // Naviguer vers la discussion après sa création
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DiscussionScreen(
                                        discussionId: discussionRef.id,
                                      ),
                                    ),
                                  );
                                } else {
                                  // La discussion existe déjà
                                  print('Discussion existante ID: ${discussionSnapshot.docs.first.id}'); // Diagnostic

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Une discussion existe déjà pour ce ticket.')),
                                  );

                                  // Naviguer vers la discussion existante
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DiscussionScreen(
                                        discussionId: discussionSnapshot.docs.first.id,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print('Erreur lors de la gestion de la discussion: $e');
                              }
                            },
                            child: Text(
                              "Approfondir la discussion",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        ],
                      )
                    else
                      Text(
                        'Vous ne pouvez pas répondre à ce ticket.',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
