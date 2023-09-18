import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PendingExchangesWidget extends StatelessWidget {
  final String loggedInUserEmail;
  final String productId;

  const PendingExchangesWidget(
      {Key? key, required this.loggedInUserEmail, required this.productId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        var product = snapshot.data!;
        if (product['op_email'] != loggedInUserEmail) {
          return const SizedBox
              .shrink(); // Don't display anything if emails don't match
        }

        // If 'op_email' matches 'loggedInUserEmail', display the exchanges
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('exchanges')
              .where('status', isEqualTo: 'pending')
              .where('productRef', isEqualTo: product.reference)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            return Container(
              height: 250, // Adjust the height to accommodate the heading
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Pending Exchanges',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.grey[900]), // Make the heading large and bold
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemBuilder: (BuildContext context, int index) {
                        var doc = snapshot.data!.docs[index];
                        return ListTile(
                          contentPadding: EdgeInsets.all(8.0),
                          title: Text(
                              'From: ${doc['senderEmail']}, Item: ${doc['item']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  doc.reference.update({'status': 'confirmed'});
                                },
                                child: const Text('Confirm'),
                              ),
                              SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () {
                                  doc.reference.update({'status': 'rejected'});
                                },
                                child: const Text('Reject'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
