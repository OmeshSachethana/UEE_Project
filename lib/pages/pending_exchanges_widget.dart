import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PendingExchangesWidget extends StatelessWidget {
  final String loggedInUserEmail;

  const PendingExchangesWidget({Key? key, required this.loggedInUserEmail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('exchanges')
          .where('status', isEqualTo: 'pending')
          .where('senderEmail', isEqualTo: loggedInUserEmail)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return ListTile(
              title: Text('From: ${doc['senderEmail']}, Item: ${doc['item']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      doc.reference.update({'status': 'confirmed'});
                    },
                    child: const Text('Confirm'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      doc.reference.update({'status': 'rejected'});
                    },
                    child: const Text('Reject'),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
