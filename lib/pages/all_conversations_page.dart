import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'test_message.dart';

class ConversationsPage extends StatefulWidget {
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
        title: Text('Conversations'),
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
          final messages = snapshot.data?.docs ?? [];
          final recipients =
              messages.map((msg) => msg['recipient']).toSet().toList();

          return ListView.builder(
            itemCount: recipients.length,
            itemBuilder: (context, index) {
              final recipient = recipients[index];

              return ListTile(
                title: Text(recipient),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MessageWidget(recipientEmail: recipient)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
