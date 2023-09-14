import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'test_message.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  late String currentUserEmail;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserEmail();
  }

  Future<void> fetchCurrentUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserEmail = user.email!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('sender', isEqualTo: currentUserEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading conversations'),
            );
          }
          final sentMessages = snapshot.data?.docs ?? [];
          final sentRecipients =
              sentMessages.map((msg) => msg['recipient']).toSet().toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('messages')
                .where('recipient', isEqualTo: currentUserEmail)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading conversations'),
                );
              }
              final receivedMessages = snapshot.data?.docs ?? [];
              final receivedSenders =
                  receivedMessages.map((msg) => msg['sender']).toSet().toList();

              final allConversations = {...sentRecipients, ...receivedSenders};

              if (allConversations.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 100.0,
                        color: Colors.grey,
                      ),
                      Text(
                        'Start a conversation with a seller',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: allConversations.length,
                  itemBuilder: (context, index) {
                    final conversation = allConversations.elementAt(index);

                    return ListTile(
                      title: Text(conversation),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MessageWidget(recipientEmail: conversation)),
                        );
                      },
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
