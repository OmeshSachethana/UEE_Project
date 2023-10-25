import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:io';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startingPriceController = TextEditingController();
  final TextEditingController timerMinutesController = TextEditingController();
  final TextEditingController timerSecondsController = TextEditingController();

  final User user = FirebaseAuth.instance.currentUser!;
  final List<String> categories = [
    'Watches',
    'Blouse',
    'Shorts',
    'Trousers',
    'Tshirts'
  ];
  String selectedCategory = 'Watches';

  String? _imageUrl;
  bool isAuctionProduct = false;

  void _handleProductTypeChange(bool? value) {
    if (value != null) {
      setState(() {
        isAuctionProduct = value;
      });
    }
  }

  Future<void> _addProduct() async {
    try {
      if (isAuctionProduct) {
        int minutes = int.parse(timerMinutesController.text);
        int seconds = int.parse(timerSecondsController.text);

        Map<String, dynamic> productData = {
          'name': titleController.text,
          'quantity': int.parse(quantityController.text),
          'description': descriptionController.text,
          'image': _imageUrl,
          'category': selectedCategory,
          'op_email': user.email,
          'product_type': isAuctionProduct ? 'auction' : 'normal',
          'timer': (minutes * 60) + seconds,
          'starting_price': double.parse(startingPriceController.text),
        };

        await FirebaseFirestore.instance
            .collection('products')
            .add(productData);
      } else {
        Map<String, dynamic> productData = {
          'name': titleController.text,
          'quantity': int.parse(quantityController.text),
          'description': descriptionController.text,
          'image': _imageUrl,
          'category': selectedCategory,
          'op_email': user.email,
          'product_type': isAuctionProduct ? 'auction' : 'normal',
        };

        await FirebaseFirestore.instance
            .collection('products')
            .add(productData);
      }

      titleController.clear();
      quantityController.clear();
      descriptionController.clear();
      startingPriceController.clear();
      timerMinutesController.clear();
      timerSecondsController.clear();
      setState(() {
        _imageUrl = null;
      });

      // Show success alert here
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Product Added Successfully!',
      );
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
        var snapshot = await FirebaseStorage.instance
            .ref()
            .child('images/${user.uid}/${DateTime.now().toString()}.jpg')
            .putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _imageUrl = downloadUrl;
        });
      }
    } catch (e) {
      print('Failed to upload image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text('Product Type:'),
                  Radio<bool>(
                    value: false,
                    groupValue: isAuctionProduct,
                    onChanged: _handleProductTypeChange,
                  ),
                  const Text('Normal'),
                  Radio<bool>(
                    value: true,
                    groupValue: isAuctionProduct,
                    onChanged: _handleProductTypeChange,
                  ),
                  const Text('Auction'),
                ],
              ),
              DropdownButtonFormField(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (category) {
                  setState(() {
                    selectedCategory = category.toString();
                  });
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
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              if (isAuctionProduct)
                Column(
                  children: [
                    TextField(
                      controller: startingPriceController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Starting Price'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: timerMinutesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Timer (minutes)'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: timerSecondsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Timer (seconds)'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _uploadImage,
                child: const Text('Upload Image'),
              ),
              if (_imageUrl != null) Image.network(_imageUrl!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_imageUrl != null) ? _addProduct : null,
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
