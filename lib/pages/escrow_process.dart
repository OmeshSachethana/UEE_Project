import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EscrowWidget extends StatefulWidget {
  final String recipientEmail;
  final String loggedInUserEmail;
  final String productId; // Add this

  const EscrowWidget(
      {Key? key,
      required this.recipientEmail,
      required this.loggedInUserEmail,
      required this.productId}) // And this
      : super(key: key);

  @override
  _EscrowWidgetState createState() => _EscrowWidgetState();
}

class _EscrowWidgetState extends State<EscrowWidget> {
  String dropdownValue = 'Select your item';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'Select the item you want to exchange:',
          style: TextStyle(fontSize: 16.0),
        ),
        DropdownButton<String>(
          value: dropdownValue,
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue!;
            });
          },
          items: <String>[
            'Select your item',
            'Item 1',
            'Item 2',
            'Item 3',
            'Item 4'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: () async {
            // Get the selected item from the dropdown
            String selectedItem = dropdownValue;

            // Get a reference to the product document in Firestore
            DocumentReference productRef = FirebaseFirestore.instance
                .collection('products')
                .doc(widget.productId);

            // Create a data object to send to Firestore
            var data = {
              'senderEmail': widget.loggedInUserEmail,
              'recipientEmail': widget.recipientEmail,
              'item': selectedItem,
              'productRef': productRef, // Add the product reference here
              'status': 'Pending',
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
          child: const Text('Exchange'),
        ),
      ],
    );
  }
}
