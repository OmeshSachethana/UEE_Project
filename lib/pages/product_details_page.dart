import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'test_message.dart';
import 'exchange/escrow_process.dart';

class ExchangePage extends StatefulWidget {
  final String opEmail;
  final String loggedInUserEmail;
  final String productId;

  const ExchangePage(
      {Key? key,
      required this.opEmail,
      required this.loggedInUserEmail,
      required this.productId})
      : super(key: key);

  @override
  _ExchangePageState createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
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
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToExchangeWidget(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exchange Items'),
          content: EscrowWidget(
            recipientEmail: widget.opEmail,
            loggedInUserEmail: widget.loggedInUserEmail,
            productId: widget.productId,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<String> getProductType() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
    return doc['product_type'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 245, 209),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            if (widget.opEmail != widget.loggedInUserEmail)
              ElevatedButton(
                onPressed: () {
                  _navigateToMessageWidget(context);
                },
                child: const Text('Message Seller'),
              ),
            FutureBuilder<String>(
              future: getProductType(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == "normal" &&
                      widget.opEmail != widget.loggedInUserEmail) {
                    return ElevatedButton(
                      onPressed: () {
                        _navigateToExchangeWidget(context);
                      },
                      child: const Text('Exchange Items'),
                    );
                  } else {
                    return Container(); // Render an empty container when product type is not "normal"
                  }
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 16.0),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
