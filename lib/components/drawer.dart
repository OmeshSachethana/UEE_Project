import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/components/my_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignoutTap;
  final void Function()? onMessageTap;
  final void Function()? onProductTap;
  final void Function()? onExchangeTap;
  final void Function()? onRecycleCenterTap;
  final void Function()? onAuctionTap;
  final void Function()? onRecyclProductTap;

  const MyDrawer(
      {super.key,
      required this.onProfileTap,
      required this.onSignoutTap,
      required this.onMessageTap,
      required this.onProductTap,
      required this.onExchangeTap,
      required this.onRecycleCenterTap,
      required this.onRecyclProductTap,
      required this.onAuctionTap});

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
          text: 'H O M E',
          onTap: () => Navigator.pop(context),
        ),

        //profile
        MyListTile(
            icon: Icons.person, text: "P R O F I L E", onTap: onProfileTap),

        //PRODUCTS
        MyListTile(
            icon: Icons.production_quantity_limits,
            text: "M Y  P R O D U C T S",
            onTap: onProductTap),

        //Exchanges
        MyListTile(
            icon: Icons.swap_horiz,
            text: "E X C H A N G E S",
            onTap: onExchangeTap),

        //messages
        FutureBuilder<int>(
          future: countUnreadConversations(),
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return MyListTile(
                icon: Icons.message,
                text: "M E S S A G E S",
                onTap: onMessageTap,
                unreadCount: snapshot.data,
              );
            }
          },
        ),

        MyListTile(
            icon: Icons.recycling,
            text: "R E C Y C L E   C E N T E R",
            onTap: onRecycleCenterTap),
        MyListTile(
            icon: Icons.recycling_sharp,
            text: "R E C Y C L E   P R O D U C T",
            onTap: onRecyclProductTap),

        MyListTile(icon: Icons.recycling, text: "auction", onTap: onAuctionTap),

        MyListTile(icon: Icons.recycling, text: "auction", onTap: onAuctionTap),

        MyListTile(
            icon: Icons.logout, text: "L O G O U T", onTap: onSignoutTap),
      ]),
    );
  }
}
