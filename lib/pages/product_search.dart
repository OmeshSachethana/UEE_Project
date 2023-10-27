import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSearch extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Search Products';

  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions for the search bar (e.g., clear search text)
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading icon (e.g., back button)
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Pass an empty string or a default value
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // The results based on the query
    return _buildSearchResults(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Suggestions shown while the user types
    return _buildSearchResults(query);
  }

  Widget _buildSearchResults(String query) {
    // Your search results based on the query
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No products found.'));
        }
        return GridView.count(
          crossAxisCount: 2,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () {
                // Navigate to the product details page for the selected product.
                // Implement the navigation logic as you did in the ProductPage.
                // You can pass the selected product's DocumentSnapshot to the details page.
              },
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
    );
  }
}
