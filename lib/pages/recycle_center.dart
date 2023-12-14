import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecycleCenter extends StatefulWidget {
  const RecycleCenter({super.key});

  @override
  State<RecycleCenter> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<RecycleCenter> {
  // text field controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nearbyTownController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _snController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final CollectionReference _items =
      FirebaseFirestore.instance.collection('recyclecenters');

  String searchText = '';
  // for create operation
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                right: 20,
                left: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Add Recycle Center",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Name', hintText: 'eg.ABC Center'),
                ),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                      labelText: 'Address', hintText: 'eg.1st Lane, Kaduwela'),
                ),
                TextField(
                  controller: _nearbyTownController,
                  decoration: const InputDecoration(
                      labelText: 'Nearby Town', hintText: 'eg.Kaduwela'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', hintText: 'eg.ann@gmail.com'),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _snController,
                  decoration: const InputDecoration(
                      labelText: 'Center NO', hintText: 'eg.1'),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _numberController,
                  decoration: const InputDecoration(
                      labelText: 'Contact Number', hintText: 'eg.07########'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Description', hintText: 'eg.Note'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final String name = _nameController.text;
                      final String address = _addressController.text;
                      final String neartown = _nearbyTownController.text;
                      final String email = _emailController.text;

                      final int? sn = int.tryParse(_snController.text);
                      final int? number = int.tryParse(_numberController.text);
                      final String description = _descriptionController.text;

                      if (number != null) {
                        await _items.add({
                          "name": name,
                          "address": address,
                          "number": number,
                          "neartown": neartown,
                          "email": email,
                          "sn": sn,
                          "description": description
                        });
                        _nameController.text = '';
                        _addressController.text = '';
                        //-------------------------------------------------
                        _nearbyTownController.text = '';
                        _emailController.text = '';

                        _snController.text = '';
                        _numberController.text = '';
                        _descriptionController.text = '';

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Add"))
              ],
            ),
          );
        });
  }

  // for Update operation
  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['name'];
      _addressController.text = documentSnapshot['address'];

      _nearbyTownController.text = documentSnapshot['neartown'].toString();
      _emailController.text = documentSnapshot['email'].toString();

      _snController.text = documentSnapshot['sn'].toString();
      _numberController.text = documentSnapshot['number'].toString();
      _descriptionController.text = documentSnapshot['description'];
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                right: 20,
                left: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Update Recycle Center Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Name', hintText: 'eg.ABC Center'),
                ),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'eg.1st lane, Kaduwela, '),
                ),
                TextField(
                  controller: _nearbyTownController,
                  decoration: const InputDecoration(
                      labelText: 'Nearby Town', hintText: 'eg.Kaduwela'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', hintText: 'eg.Ann@gmail.com'),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _snController,
                  decoration: const InputDecoration(
                      labelText: 'Center NO', hintText: 'eg.1'),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _numberController,
                  decoration: const InputDecoration(
                      labelText: 'Contact Number', hintText: 'eg.07########'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Description', hintText: 'eg.Note'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final String name = _nameController.text;
                      final String address = _addressController.text;
                      final String neartown = _nearbyTownController.text;
                      final String email = _emailController.text;

                      final int? sn = int.tryParse(_snController.text);
                      final int? number = int.tryParse(_numberController.text);
                      final String description = _descriptionController.text;
                      if (number != null) {
                        await _items.doc(documentSnapshot!.id).update({
                          "name": name,
                          "address": address,
                          "number": number,
                          "neartown": neartown,
                          "email": email,
                          "sn": sn,
                          "description": description
                        });
                        _nameController.text = '';
                        _addressController.text = '';
                        _nearbyTownController.text = '';
                        _emailController.text = '';
                        _snController.text = '';
                        _numberController.text = '';
                        _descriptionController.text = '';

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Update"))
              ],
            ),
          );
        });
  }

  // for delete operation
  Future<void> _delete(String productID) async {
    await _items.doc(productID).delete();

    // for snackBar
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have successfully deleted a itmes")));
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchText = value;
    });
  }

  bool isSearchClicked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: isSearchClicked
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 220, 231, 219),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                      hintText: 'Search..'),
                ),
              )
            : const Text('Recycle Centers'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isSearchClicked = !isSearchClicked;
                });
              },
              icon: Icon(isSearchClicked ? Icons.close : Icons.search))
        ],
      ),
      body: StreamBuilder(
        stream: _items.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            final List<DocumentSnapshot> items = streamSnapshot.data!.docs
                .where((doc) => doc['name'].toLowerCase().contains(
                      searchText.toLowerCase(),
                    ))
                .toList();
            return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = items[index];
                  return Card(
                    color: Color.fromARGB(255, 208, 231, 202),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 17,
                        backgroundColor: Color.fromARGB(255, 0, 0, 0),
                        child: Text(
                          documentSnapshot['sn'].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                      title: Text(
                        documentSnapshot['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      subtitle: Text(documentSnapshot['address'].toString()),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                color: Colors.black,
                                onPressed: () => _update(documentSnapshot),
                                icon: const Icon(Icons.edit)),
                            IconButton(
                                color: Colors.black,
                                onPressed: () => _delete(documentSnapshot.id),
                                icon: const Icon(Icons.delete)),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Create new project button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
