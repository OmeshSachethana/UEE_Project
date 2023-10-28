import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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
    sentMessages.docs.forEach((doc) =>
        batch.update(doc.reference, {'senderDeleted': true, 'isRead': true}));

    // Mark each received message as deleted by the receiver
    receivedMessages.docs.forEach((doc) =>
        batch.update(doc.reference, {'receiverDeleted': true, 'isRead': true}));

    // Commit the batch
    await batch.commit();
  }

  Future<String> fetchProfileImageURL(String conversation) async {
    // Check if the conversation is with the current user
    if (conversation != currentUserEmail) {
      // If not, fetch the profile image of the other user in the conversation
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(conversation)
          .get();
      return userDoc['profileImageURL'];
    } else {
      // If the conversation is with the current user, return a default image URL or handle this case as needed
      return 'https://www.nicepng.com/png/detail/136-1366211_group-of-10-guys-login-user-icon-png.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 245, 209),
      appBar: AppBar(
        title: Text('messages'.tr),
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
            return Center(
              child: Text('conError'.tr),
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
                return Center(
                  child: Text('conError'.tr),
                );
              }
              final receivedMessages = snapshot.data?.docs ?? [];
              final receivedSenders =
                  receivedMessages.map((msg) => msg['sender']).toSet().toList();

              final allConversations = {...sentRecipients, ...receivedSenders};

              if (allConversations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Image(
                        image: AssetImage('lib/images/noMessages.png'),
                        height: 100,
                      ),
                      const Padding(padding: EdgeInsets.only(top: 20.0)),
                      Text(
                        'conSuccess'.tr,
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 15.0),
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
                      builder: (context, streamSnapshot) {
                        final unreadMessages =
                            streamSnapshot.data?.docs.length ?? 0;

                        return FutureBuilder<String>(
                          future: fetchProfileImageURL(conversation),
                          builder: (context, futureSnapshot) {
                            if (futureSnapshot.connectionState ==
                                ConnectionState.waiting) {}

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(futureSnapshot
                                        .data ??
                                    'https://www.nicepng.com/png/detail/136-1366211_group-of-10-guys-login-user-icon-png.png'), // replace with the actual URL or path to the profile icon
                                radius: 40,
                              ),
                              title: Text(conversation,
                                  style: const TextStyle(fontSize: 20.0)),
                              trailing: unreadMessages > 0
                                  ? CircleAvatar(
                                      radius: 10.0,
                                      backgroundColor: Colors.red,
                                      child: Text(
                                        '$unreadMessages',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0),
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessageWidget(
                                        recipientEmail: conversation),
                                  ),
                                );
                                // Mark all messages in this conversation as read when the user opens the conversation
                                streamSnapshot.data?.docs.forEach((doc) {
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
                                          child: const Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
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
