import 'package:flutter/material.dart';
import 'package:new_app/pages/recycleProductEditPage.dart';

class RecycledProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  RecycledProductDetailPage({required this.productData});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = productData['imageUrl'];

    return Scaffold(
      appBar: AppBar(
        title: Text(productData['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 4, // Add elevation for a material-like effect
              margin: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(imageUrl),
                      ),
                    ),
                    padding: EdgeInsets.all(16), // Add padding here
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: ${productData['name']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Quantity: ${productData['quantity']}'),
                        SizedBox(height: 10),
                        Text('Price: \$${productData['price']}'),
                        SizedBox(height: 10),
                        Text(
                          'Description:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(productData['description']),
                        SizedBox(height: 10),
                        Text(
                          'Assigned Center: ${productData['assigned_center'] ?? "Unassigned"}',
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Assigned Status: ${productData['assigned_status'] ?? "Unassigned"}',
                        ),
                        // You can add more details here as needed
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Buttons
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for the first button
                  },
                  child: Text('Assign to Recycle center'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for the second button
                  },
                  child: Text('Find Recycle Center'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
