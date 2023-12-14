import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_app/components/drawer.dart';
import 'package:new_app/pages/AddFeedback.dart';
import 'package:new_app/pages/FeedbackList.dart';
import 'package:new_app/pages/my_products_page.dart';
import 'package:new_app/pages/product_search.dart';
import 'package:new_app/pages/profile_page.dart';
import 'package:new_app/pages/recycle_center.dart';
import 'package:new_app/pages/recycle_product.dart';
import 'package:new_app/pages/sample_product_page.dart';
import 'package:new_app/pages/all_conversations_page.dart';
import 'package:new_app/pages/exchange/exchanges_screen.dart';
import '../components/notifications.dart';
import 'auction_products_page.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;

  final List locale = [
    {"name": "ENGLISH", "locale": Locale('en', 'US')},
    {"name": "සිංහල", "locale": Locale('sin', 'SL')}
  ];

  updatelanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
  }

  builddialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: Text('language'.tr),
            content: Container(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        print(locale[index]['name']);
                        updatelanguage(locale[index]['locale']);
                      },
                      child: Text(locale[index]['name']),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.blue,
                  );
                },
                itemCount: locale.length,
              ),
            ),
          );
        });
  }

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

  void goToProductsPage(BuildContext context) {
    // Pop the menu drawer
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyProductsPage(),
      ),
    );
  }

  void goToAuctionPage(BuildContext context) {
    // Pop the menu drawer
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuctionProductsPage(),
      ),
    );
  }

  void goToExchangesPage(BuildContext context) {
    // Pop the menu drawer
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExchangesScreen(),
      ),
    );
  }

  void goToConversationsPage(BuildContext context) {
    // Pop the menu drawer
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConversationsPage(),
      ),
    );
  }

  void goToLanguageDialog(BuildContext context) {
    // Pop the menu drawer
    Navigator.pop(context);

    builddialog(context);
  }

  void goToRecyclesPage(BuildContext context) {
    // Pop the menu drawer
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecycleCenter(),
      ),
    );
  }

  void goToRecyclesProductPage(BuildContext context) {
    // Pop the menu drawer
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecycledProductsList(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("The Wall"),
        backgroundColor: Colors.grey[900],
        leading: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .where('isRead', isEqualTo: false)
              .where('recipient', isEqualTo: user.email)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  Positioned(
                    right: 18,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                    ),
                  )
                ],
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search), // This is the search icon button
            onPressed: () {
              //showSearch(context: context, delegate: ProductSearch());
            },
          ),
          buildNotificationsButton(),
          IconButton(
            onPressed: () => signUserOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: () => goToProfilePage(context),
        onSignoutTap: () => signUserOut(context),
        onMessageTap: () => goToConversationsPage(context),
        onProductTap: () => goToProductsPage(context),
        onExchangeTap: () => goToExchangesPage(context),
        onLanguageTap: () => goToLanguageDialog(context),
        onRecycleCenterTap: () => goToRecyclesPage(context),
        onAuctionTap: () => goToAuctionPage(context),
        onRecyclProductTap: () => goToRecyclesProductPage(context),
      ),
      body: ProductPage(loggedInUserEmail: user.email!),
      // Pass it here
    );
  }
}
