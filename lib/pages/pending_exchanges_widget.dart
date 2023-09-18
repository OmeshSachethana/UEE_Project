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

        return Container(
          height: 200, // specify the height as per your requirement
          child: ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (BuildContext context, int index) {
              var doc = snapshot.data!.docs[index];
              return ListTile(
                contentPadding: EdgeInsets.all(8.0),
                title:
                    Text('From: ${doc['senderEmail']}, Item: ${doc['item']}'),
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
        );
      },
    );
  }
}
