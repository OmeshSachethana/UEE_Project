import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_app/components/my_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignoutTap;
  final void Function()? onMessageTap;
  final void Function()? onProductTap;
  final void Function()? onExchangeTap;
  final void Function()? onLanguageTap;

  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSignoutTap,
    required this.onMessageTap,
    required this.onProductTap,
    required this.onExchangeTap,
    required this.onLanguageTap,
  });

  Future<int> countUnreadConversations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('recipient', isEqualTo: user.email)
          .get();

      // Create a set to store unique senders
      final senders = <String>{};

      // Add each sender to the set
      for (var doc in querySnapshot.docs) {
        senders.add((doc.data() as Map<String, dynamic>)['sender']);
      }

      // Return the count of unique senders
      return senders.length;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(children: [
        const DrawerHeader(
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: 64,
          ),
        ),
        MyListTile(
          icon: Icons.home,
          text: 'D-Home'.tr,
          onTap: () => Navigator.pop(context),
        ),

        //profile
        MyListTile(
            icon: Icons.person, text: "D-Profile".tr, onTap: onProfileTap),

        //PRODUCTS
        MyListTile(
            icon: Icons.article,
            text: "D-MyProduct".tr,
            onTap: onProductTap),

        //Exchanges
        MyListTile(
            icon: Icons.swap_horiz,
            text: "D-Exchanges".tr,
            onTap: onExchangeTap),

        MyListTile(
            icon: Icons.swap_horiz,
            text: "D-Language".tr,
            onTap:  onLanguageTap),

        //messages
        FutureBuilder<int>(
          future: countUnreadConversations(),
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return MyListTile(
                icon: Icons.message,
                text: "D-Messages".tr,
                onTap: onMessageTap,
                unreadCount: snapshot.data,
              );
            }
          },
        ),

        MyListTile(
            icon: Icons.logout, text: "D-logout".tr, onTap: onSignoutTap),
      ]),
    );
  }
}
