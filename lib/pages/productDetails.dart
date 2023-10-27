import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:new_app/pages/FeedbackList.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? productData;
  final String productId;

  ProductDetailScreen({
    required this.productData,
    required this.productId,
  });


Future<double> getAverageRating(String productId) async {
  // Reference to the 'feedbacks' collection in Firestore
  CollectionReference feedbacksCollection = FirebaseFirestore.instance.collection('feedbacks');

  // Query feedbacks for the specific product
  QuerySnapshot feedbacks = await feedbacksCollection.where('productId', isEqualTo: productId).get();

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
        backgroundColor: Colors.black,
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

            // Product Name
            Text(
              'Product Name: ${productData?['name'] ?? 'No Name'}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

            // Feedbacks Button
            Center(
              child: MaterialButton(
                onPressed: () {
                  // Navigate to the FeedbackList screen, passing the productId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedbackList(productId: productId),
                    ),
                  );
                },
                height: 50,
                minWidth: 200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                color: Colors.black,
                child: Text(
                          "Feedbacks",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
