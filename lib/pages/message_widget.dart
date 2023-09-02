import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });
}

class MessageWidget extends StatefulWidget {
  final FirebaseFirestore firestore;

  MessageWidget({required this.firestore});

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  final TextEditingController messageController = TextEditingController();
  bool isLoading = true;

  Future<String?> getUsername(String uid) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userEmail = user.email;
        if (userEmail != null) {
          // Use the user's email as the document ID
          final DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userEmail)
              .get();

          // Validate the UID
          if (userDoc.exists && userDoc.id == userEmail) {
            return userDoc['username'] as String?;
          }
        }
      }
    } catch (e) {
      print('Error fetching username: $e');
    }

    return null; // Return null if user not found or username doesn't exist or UID doesn't match
  }

  void sendMessage(String messageText) {
    final String senderId = FirebaseAuth.instance.currentUser!.uid;

    final message = Message(
      senderId: senderId,
      receiverId: 'KUuLlMlDc8XxzJETH7MTkyGk0qn2',
      text: messageText,
      timestamp: DateTime.now(),
    );

    widget.firestore.collection('messages').add({
      'senderId': message.senderId,
      'receiverId': message.receiverId,
      'text': message.text,
      'timestamp': message.timestamp, // Store as DateTime
    });

    messageController.clear();
  }

  @override
  void initState() {
    super.initState();
    // Listen for changes in the Firestore collection
    widget.firestore.collection('messages').snapshots().listen((_) {
      setState(() {
        isLoading = false; // Set isLoading to false when data is available
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Communication with the Uploader',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: messageController,
          decoration: const InputDecoration(
            labelText: 'Send a Message',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () {
            final messageText = messageController.text;
            if (messageText.isNotEmpty) {
              sendMessage(messageText);
            }
          },
          child: const Text('Send Message'),
        ),
        // Display Message (if sent)
        const SizedBox(height: 16.0),
        StreamBuilder<QuerySnapshot>(
          // Replace with your own Firestore query for displaying messages
          stream: widget.firestore.collection('messages').snapshots(),
          builder: (context, snapshot) {
            if (isLoading) {
              return const Text('Loading messages...'); // Display a loading message
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                  'No Messages Yet'); // Display a message when no data is available
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Text('No Messages Yet');
            }
            final messages =
                snapshot.data!.docs; // Use the ! operator to assert non-null
            List<Widget> messageWidgets = [];
            for (var message in messages) {
              final senderId = message['senderId'];
              final text = message['text'];
              messageWidgets.add(
                FutureBuilder<String?>(
                  future: getUsername(
                      senderId), // Fetch the username asynchronously
                  builder: (context, usernameSnapshot) {
                    if (usernameSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Text(
                          'Loading messages...'); // Display a loading message while fetching the username
                    }
                    if (usernameSnapshot.hasError ||
                        usernameSnapshot.data == null) {
                      return Text(
                          '$senderId: $text'); // Use UID if username is not available
                    }
                    final username = usernameSnapshot.data!;
                    return ListTile(
                        title: Text(
                            '$username: $text') // Display the username instead of UID
                        );
                  },
                ),
              );
            }
            return Column(
              children: messageWidgets,
            );
          },
        ),
      ],
    );
  }
}
