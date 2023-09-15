import 'package:flutter/material.dart';
import 'test_message.dart'; // Import the MessageWidget

class ExchangePage extends StatefulWidget {
  final String opEmail;
  final String loggedInUserEmail; // Add this

  const ExchangePage(
      {Key? key, required this.opEmail, required this.loggedInUserEmail})
      : super(key: key); // And this

  @override
  _ExchangePageState createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  // Function to navigate to MessageWidget
  void _navigateToMessageWidget(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Message Seller'),
          content: MessageWidget(recipientEmail: widget.opEmail),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            if (widget.opEmail != widget.loggedInUserEmail) // Add this
              ElevatedButton(
                onPressed: () {
                  // Navigate to MessageWidget when the button is pressed
                  _navigateToMessageWidget(context);
                },
                child: const Text('Message Seller'),
              ),

            // Exchange Button
            if (widget.opEmail != widget.loggedInUserEmail) // And this
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
