import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecycledProductDetailEditPage extends StatelessWidget {
  final Map<String, dynamic> productData;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController assignedStatusController;
  final TextEditingController assignedCenterMYController;
  //GoogleMapController? _controller;

  final String documentId;

  RecycledProductDetailEditPage({
    required this.productData,
    required this.nameController,
    required this.quantityController,
    required this.assignedStatusController,
    required this.assignedCenterMYController,
    required this.documentId,
    required TextEditingController descriptionController,
    required TextEditingController assignedCenterrController,
    required imageUrl,
    required TextEditingController assignedCenterController,

    //required TextEditingController assignedCenterMYController,
  });

  Future<void> _updateProductDetails() async {
    try {
      await FirebaseFirestore.instance
          .collection('recycle')
          .doc(documentId)
          .update({
        'name': nameController.text,
        'quantity': int.parse(quantityController.text),
        'assigned_status': assignedStatusController.text,
        'assigned_center': assignedCenterMYController.text,
      });
      print('Product updated successfully.');
    } catch (e) {
      print('Failed to update product: $e');
    }
  }

  Future<void> _sendEmail() async {
    final recipientEmail = productData['assigned_center_email'];
    final subject = 'Regarding Recycle Product: ${productData['name']}';
    final body =
        "Hello,\n\n I would like to discuss the recycle product ${productData['name']}.\n";

    final emailUrl = Uri(
      scheme: 'mailto',
      path: recipientEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      await launch(emailUrl.toString());
    } catch (e) {
      print('Error launching email: $e');
    }
  }

  Future<void> _openMapsToFindRecycleCenter() async {
    final recycleCenterName = assignedCenterMYController.text;

    if (recycleCenterName.isEmpty) {
      print('Please enter a recycle center name to search.');
      return;
    }

    final query =
        'Sri Lanka Recycle Center $recycleCenterName'; // You can customize the query

    // Construct the Google Maps URL with the search query
    final mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    // https://maps.google.com/maps/@37.0625,-95.677068,4z

    try {
      if (await canLaunch(mapsUrl)) {
        await launch(mapsUrl);
      } else {
        print('Could not launch $mapsUrl');
      }
    } catch (e) {
      print('Error opening maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = productData['imageUrl'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(16),
              color: Color.fromARGB(255, 229, 242, 220),
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
                    padding: EdgeInsets.all(16),
                  ),
                  ListTile(
                    title: Text(
                      'Name: ${productData['name']}',
                      style: TextStyle(
                        fontSize: 25, // Adjust the font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Quantity: ${productData['quantity']}',
                      style: TextStyle(
                        fontSize: 20, // Adjust the font size
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Assigned Status: ${productData['assigned_status']}',
                      style: TextStyle(
                        fontSize: 20, // Adjust the font size
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Assigned Center: ${productData['assigned_center']}',
                      style: TextStyle(
                        fontSize: 20, // Adjust the font size
                      ),
                    ),
                  ),
                  ListTile(
                    title: ElevatedButton(
                      onPressed: _sendEmail,
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 38, 38, 39),
                        onPrimary: Colors.white,
                      ),
                      child: Text(
                        'Send Email',
                        style: TextStyle(
                          fontSize: 20, // Set your desired font size
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              margin: EdgeInsets.all(16),
              color: Color.fromARGB(255, 229, 242,
                  220), // Set the background color for the first card
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Assign Recycle Center',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight.bold, // Set your desired font size
                      ),
                    ),
                  ),
                  ListTile(
                    title: TextField(
                      style: TextStyle(
                        fontSize: 20, // Adjust the font size
                      ),
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                  ),
                  ListTile(
                    title: TextField(
                      style: TextStyle(
                        fontSize: 20, // Adjust the font size
                      ),
                      controller: quantityController,
                      decoration: InputDecoration(labelText: 'Quantity'),
                    ),
                  ),

                  //-------------------------DropDown------------------------------------
                  ListTile(
                    title: DropdownButtonFormField<String>(
                      value: assignedStatusController.text,
                      decoration: InputDecoration(labelText: 'Assigned Status'),
                      items: ['Unassigned', 'Assigned']
                          .map((status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: Colors
                                        .black, // Set your desired font color
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        assignedStatusController.text = value!;
                      },
                      style: TextStyle(
                        fontSize: 20, // Set your desired font size
                      ),
                    ),
                  ),
                  //--------------------------------------------------------------------
                  ListTile(
                    title: TextField(
                      style: TextStyle(
                        fontSize: 20, // Adjust the font size
                      ),
                      controller: assignedCenterMYController,
                      decoration: InputDecoration(labelText: 'Assigned Center'),
                    ),
                  ),
                  ListTile(
                    title: ElevatedButton(
                      onPressed: () {
                        _updateProductDetails();

                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        primary:
                            Color.fromARGB(255, 38, 38, 39), // Background color
                        onPrimary: Colors.white, // Text color
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 20, // Set your desired font size
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: ElevatedButton(
                      onPressed:
                          _openMapsToFindRecycleCenter, // Call the new function
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 38, 38, 39),
                        onPrimary: Colors.white,
                      ),
                      child: Text(
                        'Find Recycle Center',
                        style: TextStyle(
                          fontSize: 20, // Set your desired font size
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
