import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/pages/recycled_product_detail.dart';

class RecycledProductsList extends StatelessWidget {
  RecycledProductsList(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recycled Products'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('recycle').snapshots(),
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

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              // Check if imageUrl is null or empty, and provide a default image URL
              final imageUrl =
                  data['imageUrl'] != null && data['imageUrl'].isNotEmpty
                      ? data['imageUrl']
                      : 'https://example.com/default-image-url.png';

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecycledProductDetailPage(
                        productData:
                            data, // Pass the product data to the detail page
                      ),
                    ),
                  );
                  // Add code to handle the tap action, e.g., navigate to a product detail page
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(data)));
                },
                child: Card(
                  child: ListTile(
                    title: Text(data['name']),
                    subtitle: Text(
                        'Quantity: ${data['quantity']}, ${data['assigned_status']}'),
                    leading: Image.network(imageUrl),
                    // You can add more details here if needed
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
