import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

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
          .limit(3)
          .get();

      setState(() {
        latestBids = snapshot.docs;
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
      DateTime endTime = DateTime.now().add(Duration(seconds: timerSeconds));

      if (endTime.isAfter(DateTime.now()) && mounted) {
        remainingTime = endTime.difference(DateTime.now());
        timerStreamController.add(remainingTime);
      }

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (endTime.isAfter(DateTime.now()) && mounted) {
          setState(() {
            remainingTime = endTime.difference(DateTime.now());
            timerStreamController.add(remainingTime);
          });
        } else {
          timer.cancel();
        }
      });

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
                ),
              const SizedBox(height: 20),
              if (_timerStarted)
                StreamBuilder<Duration>(
                  stream: timerStreamController.stream,
                  builder:
                      (BuildContext context, AsyncSnapshot<Duration> snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'Time Remaining: ${snapshot.data!.inMinutes} minutes ${snapshot.data!.inSeconds.remainder(60)} seconds',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      );
                    } else {
                      return Container(); // Placeholder while waiting for data
                    }
                  },
                ),
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
