import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:new_app/pages/AddFeedback.dart';
import 'package:quickalert/quickalert.dart';

class FeedbackList extends StatefulWidget {
  final String productId;

  FeedbackList({required this.productId, Key? key}) : super(key: key);

  @override
  State<FeedbackList> createState() => _FeedbackListState();
}

class _FeedbackListState extends State<FeedbackList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddFeedback(productId: widget.productId),
          )
          );
        },
        backgroundColor: Color.fromARGB(255, 28, 122, 47),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 28, 122, 47),
        centerTitle: true,
        title: Text(
          'listfeedback'.tr,
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
      ),
      body: Container(
        color: Colors.green[100],
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('feedbacks')
              .where('productId', isEqualTo: widget.productId)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            return streamSnapshot.hasData
                ? ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 10).copyWith(bottom: 3),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: Offset(2, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 11),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      streamSnapshot.data!.docs[index]['userName'],
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      streamSnapshot.data!.docs[index]['feedback'],
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                    ),
                                    // Display the rating bar with the rating value
                                    RatingBar.builder(
                                      initialRating: streamSnapshot.data!.docs[index]['rating'].toDouble(),
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: false,
                                      itemCount: 5,
                                      itemSize: 20, // Adjust the size as needed
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                      ignoreGestures: true, onRatingUpdate: (double value) {  }, // Make the rating bar non-interactive
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final docData = FirebaseFirestore.instance
                                        .collection('feedbacks')
                                        .doc(streamSnapshot.data!.docs[index]['id']);
                                    await docData.delete();
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red.shade900,
                                    size: 21,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(),
                    ),
                  );
          },
        ),
      ),
    );
  }
}
