import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:async';

import '../components/timer.dart';

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
  String highestBidderEmail = '';

  AuctionTimer auctionTimer =
      AuctionTimer(); // Create an instance of AuctionTimer

  Duration remainingTime = Duration.zero;
  Timer? _timer;
  bool _timerStarted = false;
  StreamController<Duration> timerStreamController =
      StreamController<Duration>();
  List<DocumentSnapshot> latestBids = [];

  @override
  void initState() {
    super.initState();

    // Check if timer has already started
    Map<String, dynamic>? data =
        widget.document.data() as Map<String, dynamic>?;
    _timerStarted = data?['timer_started'] ?? false;

    // If timer is started, initialize timer
    if (_timerStarted) {
      int timerSeconds = widget.document['timer'];
      DateTime createdAt =
          (widget.document['created_at'] as Timestamp).toDate();
      DateTime endTime = createdAt.add(Duration(seconds: timerSeconds));
      DateTime now = DateTime.now();
      remainingTime =
          endTime.isAfter(now) ? endTime.difference(now) : Duration.zero;

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (remainingTime.inSeconds > 0 && mounted) {
          setState(() {
            remainingTime = remainingTime - Duration(seconds: 1);
            timerStreamController
                .add(remainingTime); // Send update to the stream
          });
        } else {
          timer.cancel();
        }
      });
    }

    // Load latest bids only once when the widget is first created
    _loadLatestBids();
  }

  void _loadLatestBids() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.document.id)
          .collection('bids')
          .orderBy('bid_amount', descending: true)
          .limit(1)
          .get();

      setState(() {
        latestBids = snapshot.docs;
        highestBidderEmail =
            latestBids.isNotEmpty ? latestBids[0]['user_email'] : '';
      });
    } catch (e) {
      print('Failed to load latest bids: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer if it's not null
    timerStreamController.close(); // Close the stream controller
    super.dispose();
  }

  void _placeBid() async {
    try {
      // Check if the timer is over
      if (remainingTime.inSeconds <= 0) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Auction Ended',
          text: 'You cannot place a bid',
        );

        return;
      }

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

          // Get the current highest bid
          DocumentSnapshot? highestBid =
              latestBids.isNotEmpty ? latestBids[0] : null;
          double highestBidAmount =
              highestBid != null ? highestBid['bid_amount'] : 0.0;

          // Get the starting price
          double startingPrice = data['starting_price'];

          // Check if new bid is higher than the current highest bid and the starting price
          if (newBid <= highestBidAmount || newBid < startingPrice) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Oops...',
              text: 'Bid higher than the current highest amount',
            );
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

          // Show success alert
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Bid Added Successfully!',
          );
        }
      }
    } catch (e) {
      print('Failed to place bid: $e');
    }
  }

  void _startTimer() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.document.id)
          .update({
        'timer_started': true,
        'created_at': FieldValue.serverTimestamp(),
      });

      int timerSeconds = widget.document['timer'];

      auctionTimer.startTimer(timerSeconds, setState,
          mounted); // Use the AuctionTimer instance to start the timer

      // Call setState to trigger a UI update
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Failed to start timer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(data['name']),
      ),
      backgroundColor: Color.fromARGB(255, 218, 245, 209),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Container(
                height: 450,
                width: 400,
                child: Card(
                  child: Column(
                    children: [
                      Image.network(data['image']),
                      Card(child: Text('Category: ${data['category']}')),
                      Text('Quantity: ${data['quantity']}'),
                      Text('Description: ${data['description']}'),
                      Text('Price: ${data['starting_price']}'),
                    ],
                  ),
                ),
              ),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Current Highest Bid: ${latestBids.isNotEmpty ? latestBids[0]['bid_amount'] : 'No bids yet'}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      StreamBuilder<Duration>(
                        stream: timerStreamController.stream,
                        builder: (BuildContext context,
                            AsyncSnapshot<Duration> snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              'Time Remaining: ${snapshot.data!.inMinutes} minutes ${snapshot.data!.inSeconds.remainder(60)} seconds',
                              style: TextStyle(fontSize: 15),
                            );
                          } else {
                            return Text('Timer not started yet',
                                style: TextStyle(fontSize: 20));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (user?.email == highestBidderEmail &&
                  remainingTime.inSeconds <= 0)
                TextButton(
                  onPressed: () {
                    // Calculate total amount
                    double serviceCharge = 0.05; // 5% service charge
                    double totalAmount = latestBids.isNotEmpty
                        ? latestBids[0]['bid_amount'] * (1 + serviceCharge)
                        : 0.0;
                    String totalAmountStr = totalAmount.toStringAsFixed(
                        2); // Convert totalAmount to string with 2 decimal places

                    var transactions = [
                      {
                        "amount": {
                          "total": totalAmountStr,
                          "currency": "USD",
                          "details": {
                            "subtotal": totalAmountStr,
                            "shipping": '0',
                            "shipping_discount": 0
                          }
                        },
                        "description": "The payment transaction description.",
                        "item_list": {
                          "items": [
                            {
                              "name": "User item ${data['name']}}",
                              "quantity": 1,
                              "price": totalAmountStr,
                              "currency": "USD"
                            }
                          ],
                        }
                      }
                    ];

                    // Navigate to PayPal payment page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => UsePaypal(
                            sandboxMode: true,
                            clientId:
                                "AQnn6KdYQ7qb8AwBMK8B4LVnWau7tWmoj9XKe7V53RryuJowjeN7BLF8-JSfGCOJe1vpJu9fema6R8Qi",
                            secretKey:
                                "EGHi7FX1N2-yS-NwIi-4Ki1xZGrLQFCfF-zDHSEe5qfVb4YVGTbfsL5LlFZSCUdcldTyQvHrGdISwjNo",
                            returnURL: "https://samplesite.com/return",
                            cancelURL: "https://samplesite.com/cancel",
                            transactions: transactions,
                            note: "Contact us for any questions on your order.",
                            onSuccess: (Map params) async {
                              print("onSuccess: $params");
                            },
                            onError: (error) {
                              print("onError: $error");
                            },
                            onCancel: (params) {
                              print('cancelled: $params');
                            }),
                      ),
                    );
                  },
                  child: const Text(
                    'Make Payment',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              const SizedBox(height: 20),
              if (latestBids.isNotEmpty)
                Column(
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
                      itemCount: latestBids.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot bidDocument = latestBids[index];
                        Map<String, dynamic> bidData =
                            bidDocument.data() as Map<String, dynamic>;

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text('User: ${bidData['user_email']}'),
                            subtitle:
                                Text('Bid Amount: ${bidData['bid_amount']}'),
                            trailing: Text((bidData['timestamp'] as Timestamp)
                                .toDate()
                                .toString()),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              if (!_timerStarted && user!.email == data['op_email'])
                ElevatedButton(
                  onPressed: _startTimer,
                  child: const Text('Start Timer'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
