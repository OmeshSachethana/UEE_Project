import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'test_message.dart'; // Import the MessageWidget

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  _ExchangePageState createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to navigate to MessageWidget
  void _navigateToMessageWidget(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Message Seller'),
          content: MessageWidget(recipientEmail: 'menusha@gmail.com'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Exchange'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Details
            const Text(
              'Sample Dress',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'This is a beautiful sample dress for exchange.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),

            // Include the MessageWidget here

            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),

            // Exchange Button
            ElevatedButton(
              onPressed: () {
                // Navigate to MessageWidget when the button is pressed
                _navigateToMessageWidget(context);
              },
              child: const Text('Message Seller'),
            ),

            // Exchange Button
            ElevatedButton(
              onPressed: () {
                // Navigate to MessageWidget when the button is pressed
              },
              child: const Text('Exchange Items'),
            ),
          ],
        ),
      ),
    );
  }
}
