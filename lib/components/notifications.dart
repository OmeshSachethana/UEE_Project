import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/pages/exchange/exchanges_screen.dart';

StreamBuilder<QuerySnapshot<Object?>> buildNotificationsButton() {
  final User? user = FirebaseAuth.instance.currentUser;
  const List<String> statusOptions = ['Pending', 'Confirmed', 'Rejected'];

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('exchanges')
        .where('status', isEqualTo: 'Pending')
        .where('recipientEmail', isEqualTo: user?.email)
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return const Text('Something went wrong');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text('Loading...');
      }

      return FutureBuilder<List<PopupMenuEntry<String>>>(
        future: _buildNotificationItems(snapshot.data!.docs),
        builder: (BuildContext context,
            AsyncSnapshot<List<PopupMenuEntry<String>>> itemsSnapshot) {
          if (itemsSnapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          } else if (itemsSnapshot.hasError) {
            return Text('Error: ${itemsSnapshot.error}');
          } else {
            return PopupMenuButton<String>(
              icon: const Icon(Icons.notifications),
              offset: const Offset(0, 50),
              itemBuilder: (BuildContext context) => itemsSnapshot.data!.isEmpty
                  ? <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        enabled: false,
                        child: Text('No notifications'),
                      ),
                    ]
                  : itemsSnapshot.data!,
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

Future<List<PopupMenuEntry<String>>> _buildNotificationItems(
    List<DocumentSnapshot> docs) async {
  var notificationItems = <PopupMenuEntry<String>>[];
  for (var doc in docs) {
    var productSnapshot = await doc['productRef'].get();
    if (!productSnapshot.exists) {
      continue;
    }
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Color bgColor = Colors.white; // Default color
    if (data['status'] == 'Rejected') {
      bgColor = Colors.red[50]!; // Light red for 'Rejected'
    } else if (data['status'] == 'Confirmed') {
      bgColor = Colors.green[50]!; // Light green for 'Confirmed'
    }
    notificationItems.add(PopupMenuItem<String>(
      value: data['status'],
      child: Container(
        color: bgColor,
        child: Text(data['status'] == 'Pending'
            ? '${data['senderEmail']} is requesting an exchange'
            : 'Exchange with ${data['recipientEmail']} is ${data['status']}'),
      ),
    ));
  }
  return notificationItems;
}
