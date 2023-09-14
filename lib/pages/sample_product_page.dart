import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'exchange_page.dart';

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
            product: product,
            loggedInUserEmail: loggedInUserEmail),
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
                          Image.network(data['image'], width: 100, height: 100),
                        if (data['name'] != null)
                          Text(
                            data['name'],
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        if (data['price'] != null)
                          Text(
                            'Price: ${data['price']}',
                            style: Theme.of(context).textTheme.subtitle1,
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
              loggedInUserEmail: loggedInUserEmail) // Pass it here
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
