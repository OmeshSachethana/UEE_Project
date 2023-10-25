import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_app/pages/view_auction_product_page.dart';

class AuctionProductsPage extends StatefulWidget {
  @override
  _AuctionProductsPageState createState() => _AuctionProductsPageState();
}

class _AuctionProductsPageState extends State<AuctionProductsPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, bool> _hasStartedTimer = {};

  void _startTimer(DocumentSnapshot document) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(document.id)
          .update({
        'timer_started': true,
        'created_at': FieldValue.serverTimestamp(),
      });

      setState(() {
        _hasStartedTimer[document.id] = true;
      });
    } catch (e) {
      print('Failed to start timer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text('Auction Products'),
      ),
      backgroundColor: Color.fromARGB(255, 218, 245, 209),
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

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ViewProductPage(document: document),
                          ),
                        );
                      },
                      child: Card(
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
                              Text('Rs. ${data['starting_price']}'),
                              Text('Qty: ${data['quantity']}')
                            ],
                          ),
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
                      child: Text(
                          'Error loading products from Firestore ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // show a loading spinner while waiting for the products to load from Firestore.
                }

                return GridView.builder(
                    shrinkWrap:
                        true, // this makes the GridView take up only as much space as it needs.
                    physics:
                        NeverScrollableScrollPhysics(), // this disables scrolling within the GridView.
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            2), // this makes the GridView display two columns of items on the screen.
                    itemCount: snapshot.data!.docs
                        .length, // the number of products in the database.
                    itemBuilder: (BuildContext context, int index) {
                      // builder callback
                      DocumentSnapshot document =
                          snapshot.data!.docs[index]; // get document snapshot
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>; // get data

                      return InkWell(
                        onTap: () {
                          // handle tap events that occur within this widget.
                          Navigator.push(
                            // navigate to a new screen and/or back to the previous screen.
                            context,
                            MaterialPageRoute(
                              // a modal route that replaces the entire screen with a platform-adaptive transition.
                              builder: (context) => ViewProductPage(
                                  document:
                                      document), // returns a new widget that will be pushed onto the Navigator stack.
                            ),
                          );
                        },
                        child: Card(
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
                                  onPressed:
                                      _hasStartedTimer[document.id] == true
                                          ? null
                                          : () => _startTimer(document),
                                  child: Text('Start Timer'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
