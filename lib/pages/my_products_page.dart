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
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(primary: Colors.red),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(primary: Colors.green),
              child: const Text('Save'),
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
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(primary: Colors.red),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(primary: Colors.green),
              child: const Text('Delete'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: Colors.grey[900],
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
            return const Center(
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
            padding: const EdgeInsets.all(8.0),
            itemCount: productsByCategory.length,
            itemBuilder: (BuildContext context, int index) {
              String category = productsByCategory.keys.elementAt(index);

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: productsByCategory[category]!.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot document =
                            productsByCategory[category]![index];
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(data['name']),
                          leading: Image.network(data['image']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _showEditDialog(context, document),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    _showDeleteDialog(context, document),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        },
        backgroundColor: Colors.grey[900],
        child: const Icon(Icons.add),
      ),
    );
  }
}
