import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MessageWidget extends StatefulWidget {
  final String recipientEmail;

  const MessageWidget({super.key, required this.recipientEmail});

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  TextEditingController messageController = TextEditingController();
  late String currentUserEmail;
  File? _imageFile;

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

  Future<String?> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm'),
            content: Column(
              children: <Widget>[
                Image.file(_imageFile!),
                TextField(
                  controller: messageController,
                  decoration:
                      const InputDecoration(hintText: 'Type a message...'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _imageFile = null;
                  });
                },
              ),
              TextButton(
                child: const Text('Upload'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    // Upload to Firebase Storage
                    await FirebaseStorage.instance
                        .ref('uploads/file-to-upload.png')
                        .putFile(_imageFile!);
                    // Get the download URL
                    final String downloadURL = await FirebaseStorage.instance
                        .ref('uploads/file-to-upload.png')
                        .getDownloadURL();
                    sendMessage(imageUrl: downloadURL);
                  } on FirebaseException catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          );
        },
      );
    }
    return null;
  }

  void sendMessage({String? imageUrl}) {
    final messageText = messageController.text.trim();
    if (messageText.isNotEmpty || imageUrl != null) {
      FirebaseFirestore.instance.collection('messages').add({
        'sender': currentUserEmail,
        'senderDeleted' : false,
        'recipient': widget.recipientEmail,
        'receiverDeleted' : false,
        'text': messageText,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      messageController.clear();
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
                    final imageUrl = messages[index]['imageUrl'];
                    final isCurrentUser = sender == currentUserEmail;

                    return Container(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        margin: const EdgeInsets.all(10.0),
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
                            imageUrl != null
                                ? Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Scaffold(
                                                appBar: AppBar(
                                                  backgroundColor:
                                                      Colors.grey[900],
                                                ),
                                                body: Center(
                                                  child:
                                                      Image.network(imageUrl),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.network(imageUrl),
                                      ),
                                      Text(text),
                                    ],
                                  )
                                : Text(text),
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
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () async {
                    await uploadImage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}