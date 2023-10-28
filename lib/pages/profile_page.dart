import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Edit $field", style: const TextStyle(color: Colors.white)),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          keyboardType: (field == 'age' || field == 'contactNumber')
              ? TextInputType.number
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(newValue),
          )
        ],
      ),
    );

    if (newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  Future<void> reauthenticateUser(String password) async {
    UserCredential credential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: currentUser.email!,
      password: password,
    );
  }

  Future<void> deleteProfile() async {
    String password = "";

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            const Text("Enter Password", style: TextStyle(color: Colors.white)),
        content: TextField(
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter your password",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            password = value;
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              try {
                await reauthenticateUser(password);
                Navigator.pop(context, true);
              } catch (e) {
                // Handle reauthentication failure (e.g., incorrect password)
                print("Reauthentication failed: $e");
              }
            },
          )
        ],
      ),
    );

    if (password.isNotEmpty) {
      final bool confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Delete Profile",
              style: TextStyle(color: Colors.white)),
          content: const Text("Are you sure you want to delete your profile?",
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context, true),
            )
          ],
        ),
      );

      if (confirmDelete == true) {
        await usersCollection.doc(currentUser.email).delete();
        await currentUser.delete();
        await FirebaseAuth.instance.signOut();
        Navigator.pop(context);
      }
    }
  }

  Future<String> uploadImageToFirebaseStorage(String imagePath) async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('profile_images/${currentUser.email}.jpg');

    firebase_storage.UploadTask task = ref.putFile(File(imagePath));

    firebase_storage.TaskSnapshot snapshot = await task;
    String imageUrl = await snapshot.ref.getDownloadURL();

    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        backgroundColor: const Color.fromARGB(255, 28, 122, 47),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteProfile,
          ),
        ],
      ),
      backgroundColor: Colors.green[100],
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email!)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.data() != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await ImagePicker()
                        .getImage(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      String imagePath = pickedFile.path;
                      String imageUrl =
                          await uploadImageToFirebaseStorage(imagePath);

                      await usersCollection.doc(currentUser.email).update({
                        'profileImageURL': imageUrl,
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: userData['profileImageURL'] != null &&
                            userData['profileImageURL'].isNotEmpty
                        ? NetworkImage(userData['profileImageURL'])
                        : null,
                    child: userData['profileImageURL'] == null ||
                            userData['profileImageURL'].isEmpty
                        ? const Icon(Icons.person, size: 72)
                        : null,
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                MyTextBox(
                  text: userData['username'],
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),
                MyTextBox(
                  text: userData['age'],
                  sectionName: 'age',
                  onPressed: () => editField('age'),
                ),
                MyTextBox(
                  text: userData['contactNumber'],
                  sectionName: 'contactNumber',
                  onPressed: () => editField('contactNumber'),
                ),
                MyTextBox(
                  text: userData['address'],
                  sectionName: 'address',
                  onPressed: () => editField('address'),
                ),
                MyTextBox(
                  text: userData['city'],
                  sectionName: 'city',
                  onPressed: () => editField('city'),
                ),
                const SizedBox(height: 50),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
