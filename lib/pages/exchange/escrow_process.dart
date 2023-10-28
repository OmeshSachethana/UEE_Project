import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EscrowWidget extends StatefulWidget {
  final String recipientEmail;
  final String loggedInUserEmail;
  final String productId;

  const EscrowWidget(
      {Key? key,
      required this.recipientEmail,
      required this.loggedInUserEmail,
      required this.productId})
      : super(key: key);

  @override
  _EscrowWidgetState createState() => _EscrowWidgetState();
}

class _EscrowWidgetState extends State<EscrowWidget> {
  XFile? image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Select the item you want to\nexchange:',
              style: TextStyle(fontSize: 16.0),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10.0),
              height: 40,
              child: FloatingActionButton(
                onPressed: () async {
                  final ImagePicker _picker = ImagePicker();
                  image = await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {});
                },
                backgroundColor: Colors.green,
                child: const Icon(
                  Icons.file_upload,
                  size: 25,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        if (image != null)
          Column(
            children: <Widget>[
              Image.file(
                  File(image!.path)), // Display a preview of the selected image
            ],
          ),
        MaterialButton(
          onPressed: () async {
            if (image == null) {
              // Show a dialog indicating that no image was selected
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: const Text('No image selected.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
              return;
            }
            // Convert the image path to a list of bytes
            List<int> bytes = utf8.encode(image!.path);

            // Generate a SHA-256 hash of the bytes
            Digest digest = sha256.convert(bytes);

            // Use the hash as the image path
            Reference ref = FirebaseStorage.instance
                .ref()
                .child('buyerExchangeItems/${digest.toString()}');

            // Upload the selected image to Firebase Storage
            UploadTask uploadTask = ref.putFile(File(image!.path));

            // Wait for the upload to complete
            await uploadTask.whenComplete(() => null);

            // Get the download URL of the uploaded image
            String downloadURL = await ref.getDownloadURL();

            // Get a reference to the product document in Firestore
            DocumentReference productRef = FirebaseFirestore.instance
                .collection('products')
                .doc(widget.productId);

            // Create a data object to send to Firestore
            var data = {
              'senderEmail': widget.loggedInUserEmail,
              'recipientEmail': widget.recipientEmail,
              'item': downloadURL, // Use the download URL here
              'productRef': productRef,
              'status': 'Pending',
              'timestamp': DateTime.now(),
            };

            // Add a new document to the 'exchanges' collection in Firestore
            await FirebaseFirestore.instance.collection('exchanges').add(data);

            // Show a dialog indicating that the exchange request has been sent
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Success'),
                  content: const Text(
                      'Your exchange request has been sent. The item will be placed in escrow once the other party confirms.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
          height: 45,
          minWidth: 145,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.black,
          child: const Text(
            "Exchange",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
