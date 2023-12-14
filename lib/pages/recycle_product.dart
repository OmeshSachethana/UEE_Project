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
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('recycle').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.hasData) {
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

                return GestureDetector(
                  onTap: () {
                    // Pass the context, product data, image URL, and assigned center to the detail page
                    final nameController =
                        TextEditingController(text: data['name']);
                    final quantityController = TextEditingController(
                        text: data['quantity'].toString());
                    final assignedStatusController =
                        TextEditingController(text: data['assigned_status']);
                    final assignedCenterController =
                        TextEditingController(text: data['assigned_center']);
                    final assignedCenterMYController =
                        TextEditingController(text: data['assigned_center']);
                    final descriptionController =
                        TextEditingController(text: data['description']);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecycledProductDetailEditPage(
                          productData: data,
                          nameController: nameController,
                          quantityController: quantityController,
                          assignedStatusController: assignedStatusController,
                          assignedCenterController: assignedCenterController,
                          //-------------------------------------------------
                          assignedCenterMYController:
                              assignedCenterMYController,
                          //-------------------------------------------------
                          descriptionController: descriptionController,
                          documentId: document.id,
                          imageUrl: imageUrl,
                          assignedCenterrController: assignedCenterMYController,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(data['name']),
                      subtitle: Text(
                          'Quantity: ${data['quantity']}, Assigned Status: ${data['assigned_status']}'),
                      leading: Image.network(imageUrl),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
                child:
                    CircularProgressIndicator()); // Or some other loading indicator.
          }
        },
      ),
    );
  }
}
