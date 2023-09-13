import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageWidget extends StatefulWidget {
  final String recipientEmail;

  const MessageWidget({super.key, required this.recipientEmail});

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  TextEditingController messageController = TextEditingController();
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
    fetchCurrentUserEmail();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientEmail),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading messages'),
                  );
                }
                final allMessages = snapshot.data?.docs ?? [];
                final messages = allMessages
                    .where((msg) =>
                        (msg['sender'] == currentUserEmail &&
                            msg['recipient'] == widget.recipientEmail) ||
                        (msg['sender'] == widget.recipientEmail &&
                            msg['recipient'] == currentUserEmail))
                    .toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final sender = messages[index]['sender'];
                    final text = messages[index]['text'];
                    final isCurrentUser = sender == currentUserEmail;

                    return Container(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color:
                              isCurrentUser ? Colors.blue[100] : Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        width: MediaQuery.of(context).size.width *
                            0.6, // Adjust as needed
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(isCurrentUser ? 'You' : sender),
                            Text(text),
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
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration:
                        const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() {
    final messageText = messageController.text.trim();
    if (messageText.isNotEmpty) {
      FirebaseFirestore.instance.collection('messages').add({
        'sender': currentUserEmail,
        'recipient': widget.recipientEmail,
        'text': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      messageController.clear();
    }
  }
}
