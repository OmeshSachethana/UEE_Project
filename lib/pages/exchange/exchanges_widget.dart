import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

import 'exchange_dialog.dart';

class ExchangesWidget extends StatefulWidget {
  final String loggedInUserEmail;
  final int initialIndex;

  const ExchangesWidget(
      {Key? key, required this.loggedInUserEmail, required this.initialIndex})
      : super(key: key);

  @override
  _ExchangesWidgetState createState() => _ExchangesWidgetState();
}

class _ExchangesWidgetState extends State<ExchangesWidget> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const List<String> _statusOptions = [
    'Pending',
    'Confirmed',
    'Rejected'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 245, 209),
      body: Align(
        alignment: Alignment.topCenter,
        child: _buildBody(_statusOptions[_selectedIndex]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 218, 245, 209),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Pending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done),
            label: 'Confirmed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.close),
            label: 'Rejected',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody(String status) {
    return FutureBuilder(
      future: getExchangesStream(status).first,
      builder: (BuildContext context,
          AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(
                snapshot.data!.map((doc) => doc['productRef'].get())),
            builder: (BuildContext context,
                AsyncSnapshot<List<DocumentSnapshot>> productSnapshots) {
              if (productSnapshots.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (productSnapshots.hasError) {
                return Text('Error: ${productSnapshots.error}');
              } else {
                var validData = <QueryDocumentSnapshot>[];
                for (var i = 0; i < productSnapshots.data!.length; i++) {
                  if (productSnapshots.data![i].exists) {
                    validData.add(snapshot.data![i]);
                  }
                }
                return _buildList(validData, status);
              }
            },
          );
        }
      },
    );
  }

  Widget _buildList(List<QueryDocumentSnapshot> data, status) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'No $status Exchanges',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Image.asset(
                'lib/images/$status.png',
                height: 150,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$status Exchanges',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900]),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: data.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (BuildContext context, int index) {
              var doc = data[index];
              return FutureBuilder<DocumentSnapshot>(
                future: doc['productRef'].get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> productSnapshot) {
                  if (!productSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  var product = productSnapshot.data!;
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ExchangeDialog(
                            exchangeDetails: 'Sender: ${doc['senderEmail']}\n'
                                'Recipient: ${doc['recipientEmail']}\n'
                                'Product: ${product['name']}\n'
                                'Category: ${product['category']}\n'
                                'Quantity: ${product['quantity']}\n'
                                'Status: ${doc['status']}\n\n'
                                '${DateFormat('dd-mm-yyyy').format(doc['timestamp'].toDate())}\n',
                            imageUrl:
                                doc['senderEmail'] == widget.loggedInUserEmail
                                    ? product['image']
                                    : doc['item'],
                          );
                        },
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: doc['senderEmail'] == widget.loggedInUserEmail
                          ? (product['image'] != null
                              ? Image.network(product['image'],
                                  width: 100, height: 100)
                              : null)
                          : (doc['item'] != null
                              ? Image.network(doc['item'],
                                  width: 100, height: 100)
                              : null),
                      title: Text(product['name'] ?? '',
                          style: const TextStyle(fontSize: 20)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Category: ${product['category'] ?? ''}\n',
                              style: const TextStyle(fontSize: 16)),
                          Text('Quantity: '
                              '${product['quantity']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (doc['senderEmail'] == widget.loggedInUserEmail &&
                              status == 'Pending')
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('exchanges')
                                    .doc(doc.id)
                                    .delete();
                                setState(() {});
                              },
                            ),
                          if (product['quantity'] != null)
                            if (status == 'Pending' &&
                                doc['senderEmail'] != widget.loggedInUserEmail)
                              PopupMenuButton<String>(
                                onSelected: (String result) async {
                                  if (result == 'Confirm') {
                                    await FirebaseFirestore.instance
                                        .collection('exchanges')
                                        .doc(doc.id)
                                        .update({
                                      'status': 'Confirmed',
                                      'timestamp': Timestamp.now(),
                                    });
                                  } else if (result == 'Reject') {
                                    await FirebaseFirestore.instance
                                        .collection('exchanges')
                                        .doc(doc.id)
                                        .update({
                                      'status': 'Rejected',
                                      'timestamp': Timestamp.now(),
                                    });
                                  }
                                  setState(() {});
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'Confirm',
                                    child: Text('Confirm'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'Reject',
                                    child: Text('Reject'),
                                  ),
                                ],
                              )
                            else if (doc['senderEmail'] !=
                                widget.loggedInUserEmail)
                              ElevatedButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('exchanges')
                                      .doc(doc.id)
                                      .update({
                                    'status': doc['status'] == 'Confirmed'
                                        ? 'Rejected'
                                        : 'Confirmed',
                                    'timestamp': Timestamp.now(),
                                  });
                                  setState(() {});
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          doc['status'] == 'Confirmed'
                                              ? const Color.fromARGB(
                                                  255, 255, 100, 88)
                                              : Colors.blue),
                                ),
                                child: Text(doc['status'] == 'Confirmed'
                                    ? 'Reject'
                                    : 'Confirm'),
                              ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<List<QueryDocumentSnapshot>> getExchangesStream(String status) {
    var stream1 = FirebaseFirestore.instance
        .collection('exchanges')
        .where('status', isEqualTo: status)
        .where('recipientEmail', isEqualTo: widget.loggedInUserEmail)
        .orderBy('timestamp', descending: true)
        .snapshots();
    var stream2 = FirebaseFirestore.instance
        .collection('exchanges')
        .where('status', isEqualTo: status)
        .where('senderEmail', isEqualTo: widget.loggedInUserEmail)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot,
            List<QueryDocumentSnapshot>>(
        stream1,
        stream2,
        (QuerySnapshot snapshot1, QuerySnapshot snapshot2) =>
            snapshot1.docs + snapshot2.docs);
  }
}
