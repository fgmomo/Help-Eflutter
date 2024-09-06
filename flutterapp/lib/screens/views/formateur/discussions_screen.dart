import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/config/config.dart';
import 'package:intl/intl.dart';

class DiscussionScreen extends StatefulWidget {
  final String discussionId;

  const DiscussionScreen({super.key, required this.discussionId});

  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String currentUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          currentUserId = user.uid;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
      // Gérer les erreurs de récupération des données
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || isLoading) return;

    try {
      await FirebaseFirestore.instance.collection('discussions')
          .doc(widget.discussionId)
          .collection('messages')
          .add({
        'text': _messageController.text,
        'sender_id': currentUserId,
        'timestamp': Timestamp.now(),
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Discussion'),
          backgroundColor: primColor,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Discussion'),
        backgroundColor: primColor,
      ),
      body: Column(
        children: [
         Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('discussions')
        .doc(widget.discussionId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text('Aucun message'));
      }

      return ListView.builder(
        controller: _scrollController,
        reverse: true,
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          var message = snapshot.data!.docs[index];
          bool isCurrentUser = message['sender_id'] == currentUserId;

          return Align(
            alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                      fontSize: 16,
                      color: isCurrentUser ? Colors.black : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message['timestamp'].toDate()),
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentUser ? Colors.black : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ),
),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Entrez votre message...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text('Envoyer'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: primColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
