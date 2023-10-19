import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'product_details_page.dart';

class ProductPage extends StatelessWidget {
  final String loggedInUserEmail;

  const ProductPage({Key? key, required this.loggedInUserEmail})
      : super(key: key);

  void navigateToProductDetails(
      BuildContext context, DocumentSnapshot product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(
            product: product, loggedInUserEmail: loggedInUserEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          return GridView.count(
            crossAxisCount: 2,
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () => navigateToProductDetails(context, document),
                child: Center(
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        if (data['image'] != null)
                          Image.network(data['image'], width: 170, height: 100),
                        const SizedBox(height: 15),
                        if (data['name'] != null)
                          Text(
                            data['name'],
                            style: const TextStyle(fontSize: 15),
                          ),
                        if (data['price'] != null) const SizedBox(height: 15),
                        Text(
                          'Price: ${data['price']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  final DocumentSnapshot product;
  final String loggedInUserEmail; // Add this

  const ProductDetailsPage(
      {Key? key, required this.product, required this.loggedInUserEmail})
      : super(key: key); // And this

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = product.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: data['name'] != null ? Text(data['name']) : const Text(''),
        backgroundColor: Colors.grey[900],
      ),
      body: GestureDetector(
          child: ExchangePage(
              opEmail: data['op_email'],
              loggedInUserEmail: loggedInUserEmail,
              productId: product.id) // Pass it here
          // child: Center(
          //   child: Text(
          //     'Details for ${data['Name']}',
          //     style: Theme.of(context).textTheme.headline4,
          //   ),
          // ),
          ),
    );
  }
}
