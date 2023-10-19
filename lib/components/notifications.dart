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

      List<PopupMenuEntry<String>> notificationItems =
          snapshot.data!.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
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
    },
  );
}
