import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/pages/productDetails.dart';
import 'package:new_app/pages/product_details_page.dart';

class ProductsView extends StatefulWidget {
  final String productType; // Add productType parameter

  ProductsView({Key? key, required this.productType}) : super(key: key);

  @override
  _ProductsViewState createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  String searchText = ''; // To store the search text

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          // Filter the products based on the search text and product type
          final filteredProducts = snapshot.data!.docs.where((product) {
            final data = product.data() as Map<String, dynamic>?;
            return data != null &&
                data['name'] != null &&
                data['name'].toLowerCase().contains(searchText.toLowerCase()) &&
                (widget.productType == 'all' || data['productType'] == widget.productType); // Filter by productType
          }).toList();
          return Column(
            children: <Widget>[
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for products...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    childAspectRatio: 0.7, // Adjust this for the desired aspect ratio
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic>? data =
                        filteredProducts[index].data() as Map<String, dynamic>?;
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the product detail screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productData: data,
                              productId: filteredProducts[index].id,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4, // Add a drop shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0), // Add rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0), // Add padding to the card
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 120, // Adjust the image height
                                width: double.infinity,
                                child: Image.network(data?['image'] ?? ''), // Provide a default URL
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(data?['name'] ?? 'No Name',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(data?['description'] ?? 'No Description'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("\$${data?['price'] ?? 0.0}"), // Provide a default value
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
