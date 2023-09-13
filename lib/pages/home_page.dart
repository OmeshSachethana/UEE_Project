import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/components/drawer.dart';
import 'package:new_app/pages/profile_page.dart';
import 'package:new_app/pages/sample_product_page.dart';
import 'package:new_app/pages/all_conversations_page.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;

  // Sign out user
  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
  }

  void goToProfilePage(BuildContext context) {
    // Pop the menu drawer
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  void goToConversationsPage(BuildContext context) {
    // Pop the menu drawer
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Wall'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            onPressed: () => signUserOut(context),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: () => goToProfilePage(context),
        onSignoutTap: () => signUserOut(context),
        onMessageTap: () => goToConversationsPage(context),
      ),
      body: ProductPage(loggedInUserEmail: user.email!), // Pass it here
    );
  }
}
