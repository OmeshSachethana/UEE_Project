import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewProductPage extends StatefulWidget {
  final DocumentSnapshot document;

  ViewProductPage({required this.document});

  @override
  _ViewProductPageState createState() => _ViewProductPageState();
}

class _ViewProductPageState extends State<ViewProductPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController bidController = TextEditingController();
  bool canPlaceBid = true;

  void _placeBid() async {
    try {
      double newBid = double.parse(bidController.text);

      if (user != null && widget.document.exists) {
        Map<String, dynamic>? data =
            widget.document.data() as Map<String, dynamic>?;

        if (data != null) {
          String opEmail = data['op_email'];

          if (opEmail == user?.email) {
            // Current user is the owner of the product, don't allow bidding.
            print("You cannot bid on your own product.");
            return;
          }

          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.document.id)
              .collection('bids')
              .add({
            'user_email': user?.email,
            'bid_amount': newBid,
            'timestamp': FieldValue.serverTimestamp(),
          });

          setState(() {
            canPlaceBid = false;
          });
        }
      }
    } catch (e) {
      print('Failed to place bid: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text('Category: ${data['category']}'),
              Text('Quantity: ${data['quantity']}'),
              Text('Description: ${data['description']}'),
              Image.network(data['image']),
              const SizedBox(height: 20),
              if (!canPlaceBid)
                const Text('You have already placed a bid on this product.'),
              if (canPlaceBid &&
                  user != null &&
                  widget.document.exists &&
                  data['op_email'] != user?.email)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: bidController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Bid Amount',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _placeBid,
                      child: const Text('Place Bid'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.document.id)
                    .collection('bids')
                    .orderBy('bid_amount', descending: true)
                    .limit(3)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Latest Bids',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot bidDocument =
                              snapshot.data!.docs[index];
                          Map<String, dynamic> bidData =
                              bidDocument.data() as Map<String, dynamic>;

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text('User: ${bidData['user_email']}'),
                              subtitle:
                                  Text('Bid Amount: ${bidData['bid_amount']}'),
                              trailing: Text(
                                bidData.containsKey('timestamp') &&
                                        bidData['timestamp'] != null
                                    ? (bidData['timestamp'] as Timestamp)
                                        .toDate()
                                        .toString()
                                    : 'Timestamp not available',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.document.id)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
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

                  bool isOwner = snapshot.data!['op_email'] == user!.email;
                  bool timerStarted = snapshot.data!['timer_started'];

                  if (isOwner && !timerStarted) {
                    return ElevatedButton(
                      onPressed: _startTimer,
                      child: const Text('Start Timer'),
                    );
                  }

                  Timestamp? endTime = snapshot.data!['timer_end'];

                  if (endTime != null) {
                    DateTime endDateTime = endTime.toDate();
                    DateTime now = DateTime.now();
                    Duration remainingTime = endDateTime.isAfter(now)
                        ? endDateTime.difference(now)
                        : const Duration(seconds: 0);

                    return Text(
                      'Time Remaining: ${remainingTime.inMinutes} minutes ${remainingTime.inSeconds.remainder(60)} seconds',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTimer() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.document.id)
          .update({
        'timer_started': true,
      });
    } catch (e) {
      print('Failed to start timer: $e');
    }
  }
}
