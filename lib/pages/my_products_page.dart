import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_product.dart'; // Import the AddProductPage

class MyProductsPage extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('op_email', isEqualTo: user.email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          Map<String, List<DocumentSnapshot>> productsByCategory = {};

          snapshot.data!.docs.forEach((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String category = data['category'];

            if (!productsByCategory.containsKey(category)) {
              productsByCategory[category] = [];
            }

            productsByCategory[category]!.add(document);
          });

          return ListView.builder(
            itemCount: productsByCategory.length,
            itemBuilder: (BuildContext context, int index) {
              String category = productsByCategory.keys.elementAt(index);

              return Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      category,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: productsByCategory[category]!.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot document =
                          productsByCategory[category]![index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(data['name']),
                        leading:
                            Image.network(data['image']), // Display image here
                        // Add other product details as needed
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
