import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final User user = FirebaseAuth.instance.currentUser!;

  final List<String> categories = ['Watches', 'Blouse', 'Shorts', 'Trousers'];
  String selectedCategory = 'Watches';

  String? _imageUrl;
  late String currentUserEmail;
  File? _imageFile;

  Future<void> _addProduct() async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': titleController.text,
        'quantity': int.parse(quantityController.text),
        'price': double.parse(priceController.text),
        'description': descriptionController.text,
        'image': _imageUrl,
        'category': selectedCategory,
        'op_email': user.email,
      });

      // Clear the text fields after adding the product
      titleController.clear();
      quantityController.clear();
      priceController.clear();
      descriptionController.clear();
      setState(() {
        _imageUrl = null;
      });
    } catch (e) {
      print('Failed to add product: $e');
    }
  }

  Future<void> _uploadImage() async {
    try {
      final pickedFile =
          await ImagePicker().getImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm'),
              content: Column(
                children: <Widget>[
                  Image.file(file),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Upload'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    var snapshot = await FirebaseStorage.instance
                        .ref()
                        .child('image')
                        .putFile(file);
                    var downloadUrl = await snapshot.ref.getDownloadURL();

                    setState(() {
                      _imageUrl = downloadUrl;
                    });
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Failed to upload image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              DropdownButtonFormField(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (category) {
                  selectedCategory = category.toString();
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
              ),
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
              ElevatedButton(
                onPressed: _uploadImage,
                child: const Text('Upload Image'),
              ),
              if (_imageUrl != null) Image.network(_imageUrl!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_imageUrl != null)
                    ? _addProduct
                    : null, // Disable the button if no image is uploaded
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
