import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ExchangesWidget extends StatefulWidget {
  final String loggedInUserEmail;

  const ExchangesWidget({Key? key, required this.loggedInUserEmail})
      : super(key: key);

  @override
  _ExchangesWidgetState createState() => _ExchangesWidgetState();
}

class _ExchangesWidgetState extends State<ExchangesWidget> {
  int _selectedIndex = 0;
  static const List<String> _statusOptions = [
    'Pending',
    'Confirmed',
    'Rejected'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: _buildBody(_statusOptions[_selectedIndex]),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return _buildList(snapshot.data!, status);
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Image.asset(
                'lib/images/$status.png',
                width: 100,
                height: 100,
                color: Color.fromRGBO(255, 255, 255, 0.896),
                colorBlendMode: BlendMode.lighten,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      child: Column(
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
                    return ListTile(
                      contentPadding: EdgeInsets.all(8.0),
                      leading: product['image'] != null
                          ? Image.network(product['image'],
                              width: 50, height: 50)
                          : null,
                      title: Text(product['name'] ?? ''),
                      subtitle: Text('Category:${product['category'] ?? ''}'),
                      trailing: product['price'] != null &&
                              product['quantity'] != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Price:${product['price']}\nQuantity:'
                                    '${product['quantity']}'),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('exchanges')
                                          .doc(doc.id)
                                          .update({
                                        'status': doc['status'] == 'Confirmed'
                                            ? 'Rejected'
                                            : 'Confirmed'
                                      });
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
                                ),
                              ],
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<QueryDocumentSnapshot>> getExchangesStream(String status) {
    var stream1 = FirebaseFirestore.instance
        .collection('exchanges')
        .where('status', isEqualTo: status)
        .where('recipientEmail', isEqualTo: widget.loggedInUserEmail)
        .snapshots();
    var stream2 = FirebaseFirestore.instance
        .collection('exchanges')
        .where('status', isEqualTo: status)
        .where('senderEmail', isEqualTo: widget.loggedInUserEmail)
        .snapshots();

    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot,
            List<QueryDocumentSnapshot>>(
        stream1,
        stream2,
        (QuerySnapshot snapshot1, QuerySnapshot snapshot2) =>
            snapshot1.docs + snapshot2.docs);
  }
}
