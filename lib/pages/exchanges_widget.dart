import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ExchangesWidget extends StatelessWidget {
  final String loggedInUserEmail;
  final String status;

  const ExchangesWidget(
      {Key? key, required this.loggedInUserEmail, required this.status})
      : super(key: key);

  Stream<List<QueryDocumentSnapshot>> getExchangesStream() {
    var stream1 = FirebaseFirestore.instance
        .collection('exchanges')
        .where('status', isEqualTo: status)
        .where('recipientEmail', isEqualTo: loggedInUserEmail)
        .snapshots();
    var stream2 = FirebaseFirestore.instance
        .collection('exchanges')
        .where('status', isEqualTo: status)
        .where('senderEmail', isEqualTo: loggedInUserEmail)
        .snapshots();

    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot,
            List<QueryDocumentSnapshot>>(
        stream1,
        stream2,
        (QuerySnapshot snapshot1, QuerySnapshot snapshot2) =>
            snapshot1.docs + snapshot2.docs);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: getExchangesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        if (snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'No $status exchanges',
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
          height: 250,
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
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    var doc = snapshot.data![index];
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
                          subtitle:
                              Text('Category: ${product['category'] ?? ''}'),
                          trailing: product['price'] != null &&
                                  product['quantity'] != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Price: ${product['price']}\nQuantity:'
                                        ' ${product['quantity']}'),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('exchanges')
                                              .doc(doc.id)
                                              .update({
                                            'status':
                                                doc['status'] == 'Confirmed'
                                                    ? 'Rejected'
                                                    : 'Confirmed'
                                          });
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  doc['status'] == 'Confirmed'
                                                      ? const Color.fromARGB(255, 255, 100, 88)
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
      },
    );
  }
}
