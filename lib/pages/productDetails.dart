import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:new_app/pages/FeedbackList.dart';

import 'exchange/escrow_process.dart';
import 'test_message.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? productData;
  final String productId;
  final String opEmail;
  final String loggedInUserEmail;

  ProductDetailScreen({
    required this.productData,
    required this.productId,
    required this.opEmail,
    required this.loggedInUserEmail,
  });

  void _navigateToMessageWidget(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Message Seller'),
          content: MessageWidget(recipientEmail: opEmail),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToExchangeWidget(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exchange Items'),
          content: EscrowWidget(
            recipientEmail: opEmail,
            loggedInUserEmail: loggedInUserEmail,
            productId: productId,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<String> getProductType() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();
    return doc['product_type'];
  }

  Future<double> getAverageRating(String productId) async {
    // Reference to the 'feedbacks' collection in Firestore
    CollectionReference feedbacksCollection =
        FirebaseFirestore.instance.collection('feedbacks');

    // Query feedbacks for the specific product
    QuerySnapshot feedbacks = await feedbacksCollection
        .where('productId', isEqualTo: productId)
        .get();

    // Check if there are any feedbacks
    if (feedbacks.docs.isNotEmpty) {
      double totalRating = 0;
      int feedbackCount = feedbacks.docs.length;

      // Calculate the total rating
      for (QueryDocumentSnapshot feedback in feedbacks.docs) {
        totalRating += feedback['rating'] as double;
      }

      // Calculate the average rating
      double averageRating = totalRating / feedbackCount;
      return averageRating;
    } else {
      // If there are no feedbacks, return a default value (e.g., 0)
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productData?['name'] ?? 'Product Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 200,
              width: double.infinity,
              child: Image.network(productData?['image'] ?? ''),
            ),

            SizedBox(height: 20),

            // Product Name and Chat Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product Name: ${productData?['name'] ?? 'No Name'}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (opEmail != loggedInUserEmail)
                  Container(
                    height: 45.0,
                    width: 45.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        _navigateToMessageWidget(context);
                      },
                      child: Icon(Icons.chat, size: 25.0),
                      backgroundColor: Colors.orange,
                    ),
                  ),
              ],
            ),

            // Gap
            SizedBox(height: 20),

            // Product Description
            Text(
              'Description: ${productData?['description'] ?? 'No Description'}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            // Gap
            SizedBox(height: 20),

            // Product Price
            Text(
              'Price: \$${productData?['price'] ?? 0.0}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),

            // Gap
            SizedBox(height: 20),

            // Average Rating
            FutureBuilder<double>(
              future: getAverageRating(productId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Average Rating: Loading...');
                } else if (snapshot.hasError) {
                  return Text('Average Rating: Error');
                } else {
                  final averageRating = snapshot.data ?? 0.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Rating: ${averageRating.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // Increased the size of the RatingBar
                      RatingBarIndicator(
                        rating: averageRating,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 35, // Increased the size
                        ),
                        itemCount: 5,
                        itemSize: 35, // Increased the size
                        direction: Axis.horizontal,
                      ),
                    ],
                  );
                }
              },
            ),

            // Gap
            SizedBox(height: 20),

            // Exchanges Button
            FutureBuilder<String>(
              future: getProductType(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == "normal" &&
                      opEmail != loggedInUserEmail) {
                    return ElevatedButton(
                      onPressed: () {
                        _navigateToExchangeWidget(context);
                      },
                      child: const Text('Exchange Items'),
                    );
                  } else {
                    return Container(); // Render an empty container when product type is not "normal"
                  }
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),

            // Feedbacks Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the FeedbackList screen, passing the productId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedbackList(productId: productId),
                    ),
                  );
                },
                child: Text(
                  'Feedbacks',
                  style: TextStyle(fontSize: 24), // Increased the font size
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
