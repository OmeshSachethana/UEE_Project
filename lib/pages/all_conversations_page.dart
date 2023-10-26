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

  Future<void> deleteConversation(String conversation) async {
    // Get the collection reference
    final messagesRef = FirebaseFirestore.instance.collection('messages');

    // Create a query for messages sent by the current user to the conversation partner
    final sentMessagesQuery = messagesRef
        .where('sender', isEqualTo: currentUserEmail)
        .where('recipient', isEqualTo: conversation);

    // Create a query for messages received by the current user from the conversation partner
    final receivedMessagesQuery = messagesRef
        .where('sender', isEqualTo: conversation)
        .where('recipient', isEqualTo: currentUserEmail);

    // Get the documents for each query
    final sentMessages = await sentMessagesQuery.get();
    final receivedMessages = await receivedMessagesQuery.get();

    // Start a batch for multiple operations
    final batch = FirebaseFirestore.instance.batch();

    // Mark each sent message as deleted by the sender
    sentMessages.docs
        .forEach((doc) => batch.update(doc.reference, {'senderDeleted': true}));

    // Mark each received message as deleted by the receiver
    receivedMessages.docs.forEach(
        (doc) => batch.update(doc.reference, {'receiverDeleted': true}));

    // Commit the batch
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 245, 209),
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('sender', isEqualTo: currentUserEmail)
            .where('senderDeleted',
                isEqualTo:
                    false) // Only fetch conversations that the sender has not deleted
            .snapshots(),
        builder: (context, snapshot) {
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
                .where('receiverDeleted',
                    isEqualTo:
                        false) // Only fetch conversations that the receiver has not deleted
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
                      Image(
                        image: AssetImage('lib/images/noMessages.png'),
                        height: 100,
                      ),
                      Padding(padding: EdgeInsets.only(top: 20.0)),
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

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('messages')
                          .where('recipient', isEqualTo: currentUserEmail)
                          .where('sender', isEqualTo: conversation)
                          .where('isRead', isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final unreadMessages = snapshot.data?.docs.length ?? 0;

                        return ListTile(
                          title: Text(conversation),
                          trailing: unreadMessages > 0
                              ? CircleAvatar(
                                  radius: 10.0,
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    '$unreadMessages',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12.0),
                                  ),
                                )
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MessageWidget(recipientEmail: conversation),
                              ),
                            );
                            // Mark all messages in this conversation as read when the user opens the conversation
                            snapshot.data?.docs.forEach((doc) {
                              doc.reference.update({'isRead': true});
                            });
                          },
                          onLongPress: () async {
                            final confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text(
                                      'Are you sure you want to delete this conversation?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    ),
                                    TextButton(
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmDelete == true) {
                              await deleteConversation(conversation);
                            }
                          },
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
