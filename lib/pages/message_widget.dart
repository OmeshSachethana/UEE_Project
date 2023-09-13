import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message_model.dart';

class MessageWidget extends StatefulWidget {
  final FirebaseFirestore firestore;

  const MessageWidget({Key? key, required this.firestore}) : super(key: key);

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
          final DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(
                  userEmail) // Use the authenticated user's email as the document ID
              .get();

          // Validate the UID
          if (userDoc.exists) {
            return userDoc['username'] as String?;
          }
        }
      }
    } catch (e) {
      print('Error fetching username: $e');
    }

    return null;
  }

  void sendMessage(String messageText) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final String senderId = user.uid;

      final message = Message(
        senderId: senderId,
        receiverId: 'pSrLbo7Q5Wdp0SDa0F0WUIBKQUu1',
        text: messageText,
        timestamp: DateTime.now(),
      );

      widget.firestore.collection('messages').add({
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'text': message.text,
        'timestamp': message.timestamp,
      });

      messageController.clear();
    }
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
        // Inside the StreamBuilder builder method...
        isLoading
            ? CircularProgressIndicator() // Display a loading indicator for the entire message component
            : StreamBuilder<QuerySnapshot>(
                stream: widget.firestore.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      'No Messages Yet',
                    );
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Text('No Messages Yet');
                  }
                  final messages = snapshot.data!.docs;

                  // Reverse the order of messages
                  messages.sort((a, b) {
                    final timestampA = a['timestamp'] as Timestamp;
                    final timestampB = b['timestamp'] as Timestamp;
                    return timestampA.compareTo(timestampB);
                  });

                  List<Widget> messageWidgets = [];
                  for (var message in messages) {
                    final senderId = message['senderId'];
                    final text = message['text'];
                    messageWidgets.add(
                      FutureBuilder<String?>(
                        initialData: null, // Start with no initial data
                        future: getUsername(senderId),
                        builder: (context, usernameSnapshot) {
                          if (usernameSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(); // Initially show nothing
                          }
                          if (usernameSnapshot.hasError) {
                            return Text('$senderId: $text');
                          }
                          final username = usernameSnapshot.data ?? senderId;

                          return ListTile(
                            title: Text(
                              '$username: $text',
                            ),
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
