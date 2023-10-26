import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/pages/exchange/exchanges_screen.dart';
import 'package:async/async.dart';

StreamBuilder<List<QuerySnapshot<Object?>>?> buildNotificationsButton() {
  final User? user = FirebaseAuth.instance.currentUser;
  const List<String> statusOptions = ['Pending', 'Confirmed', 'Rejected'];

  final Stream<QuerySnapshot> senderStream = FirebaseFirestore.instance
      .collection('exchanges')
      .where('status', isEqualTo: 'Pending')
      .where('recipientEmail', isEqualTo: user?.email)
      .snapshots();

  final Stream<QuerySnapshot> recipientStream = FirebaseFirestore.instance
      .collection('exchanges')
      .where('status', whereIn: ['Confirmed', 'Rejected'])
      .where('senderEmail', isEqualTo: user?.email)
      .snapshots();

  return StreamBuilder<List<QuerySnapshot<Object?>>?>(
    stream: StreamZip([senderStream, recipientStream]),
    builder: (BuildContext context,
        AsyncSnapshot<List<QuerySnapshot<Object?>>?> snapshot) {
      if (snapshot.hasError) {
        return const Text('Something went wrong');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text('Loading...');
      }

      return FutureBuilder<List<DocumentSnapshot>>(
        future: Future.wait(snapshot.data!
            .expand((querySnapshot) => querySnapshot.docs)
            .map((doc) => doc['productRef'].get())),
        builder: (BuildContext context,
            AsyncSnapshot<List<DocumentSnapshot>> productSnapshots) {
          if (productSnapshots.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (productSnapshots.hasError) {
            return Text('Error: ${productSnapshots.error}');
          } else {
            var validData = <DocumentSnapshot>[];
            for (var i = 0; i < productSnapshots.data!.length; i++) {
              if (productSnapshots.data![i].exists) {
                validData.add(snapshot.data!
                    .expand((querySnapshot) => querySnapshot.docs)
                    .toList()[i]);
              }
            }

            List<PopupMenuEntry<String>> notificationItems =
                validData.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              Color bgColor = Colors.white; // Default color
              if (data['status'] == 'Rejected') {
                bgColor = Colors.red[50]!; // Light red for 'Rejected'
              } else if (data['status'] == 'Confirmed') {
                bgColor = Colors.green[50]!; // Light green for 'Confirmed'
              }
              return PopupMenuItem<String>(
                value: data['status'],
                child: Container(
                  color: bgColor,
                  child: Text(data['status'] == 'Pending'
                      ? '${data['senderEmail']} is requesting an exchange'
                      : 'Exchange with ${data['recipientEmail']} is ${data['status']}'),
                ),
              );
            }).toList();

            return PopupMenuButton<String>(
              icon: const Icon(Icons.notifications),
              offset: const Offset(0, 50),
              itemBuilder: (BuildContext context) => notificationItems.isEmpty
                  ? <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        enabled: false,
                        child: Text('No notifications'),
                      ),
                    ]
                  : notificationItems,
              onSelected: (String? value) {
                if (value != null && user != null && user.email != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExchangesScreen(
                        initialIndex: statusOptions.indexOf(value),
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      );
    },
  );
}
