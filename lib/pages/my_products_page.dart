import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_product.dart'; // Import the AddProductPage

class MyProductsPage extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser!;

  void _showEditDialog(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    TextEditingController titleController =
        TextEditingController(text: data['name']);
    TextEditingController quantityController =
        TextEditingController(text: data['quantity'].toString());
    TextEditingController priceController =
        TextEditingController(text: data['price'].toString());
    TextEditingController descriptionController =
        TextEditingController(text: data['description']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(document.id)
                      .update({
                    'name': titleController.text,
                    'quantity': int.parse(quantityController.text),
                    'price': double.parse(priceController.text),
                    'description': descriptionController.text,
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Failed to update product: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(document.id)
                      .delete();
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Failed to delete product: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showRecycleDialog(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    TextEditingController titleController =
        TextEditingController(text: data['name']);
    TextEditingController quantityController =
        TextEditingController(text: data['quantity'].toString());
    TextEditingController priceController =
        TextEditingController(text: data['price'].toString());
    TextEditingController descriptionController =
        TextEditingController(text: data['description']);
    TextEditingController imageUrlController =
        TextEditingController(text: data['image']);

    // Add these two TextEditingController objects
    TextEditingController assignedCenterController =
        TextEditingController(text: null);
    TextEditingController assignedStatusController =
        TextEditingController(text: "Unassigned"); // Set the default value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Recycle Product'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                ),
                // Add fields for assigned_center and assigned_status
                TextField(
                  controller: assignedCenterController,
                  decoration: InputDecoration(labelText: 'Assigned Center'),
                ),
                TextField(
                  controller: assignedStatusController,
                  decoration: InputDecoration(labelText: 'Assigned Status'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Recycle'),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('recycle').add({
                    'name': titleController.text,
                    'quantity': int.parse(quantityController.text),
                    'price': double.parse(priceController.text),
                    'description': descriptionController.text,
                    'imageUrl': imageUrlController.text,
                    // Add the new fields and set their default values
                    'assigned_center': assignedCenterController.text,
                    'assigned_status': assignedStatusController.text,
                  });
                  // Delete the product from the "products" collection
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(document.id)
                      .delete();
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Failed to recycle product: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  //-----------------------------------------------------------------------

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
      backgroundColor: Color.fromARGB(255, 218, 245, 209),
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

                      return Card(
                        // Wrap ListTile with a Card
                        child: ListTile(
                          title: Text(data['name']),
                          subtitle: Text(
                              'Quantity: ${data['quantity']}, Price: ${data['price']}'), // Display quantity and price here
                          leading: Image.network(
                              data['image']), // Display image here
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () =>
                                    _showEditDialog(context, document),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () =>
                                    _showDeleteDialog(context, document),
                              ),
                              IconButton(
                                icon: Icon(Icons.recycling),
                                onPressed: () =>
                                    _showRecycleDialog(context, document),
                              ),
                            ],
                          ), // Add other product details as needed
                        ),
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
