import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_app/pages/view_auction_product_page.dart';

class AuctionProductsPage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  void _startTimer(DocumentSnapshot document) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(document.id)
          .update({
        'timer_started': true,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to start timer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auction Products'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Ongoing Auctions
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Ongoing Auctions',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('product_type', isEqualTo: 'auction')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Container(
                                width: 130,
                                height: 100,
                                child: Image.network(data['image'])),
                            Text(data['name']),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewProductPage(document: document),
                                  ),
                                );
                              },
                              child: Text('View Product'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // My Auctions
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('My Auctions',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('product_type', isEqualTo: 'auction')
                  .where('op_email', isEqualTo: user?.email)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ListTile(
                        title: Text(data['name']),
                        leading: Image.network(data['image']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewProductPage(document: document),
                                  ),
                                );
                              },
                              child: Text('View Product'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _startTimer(document),
                              child: Text('Start Timer'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
