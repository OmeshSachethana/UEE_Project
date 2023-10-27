import 'dart:ffi';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';

class AddFeedback extends StatefulWidget {
  final String userName;
  final String feedback;
  final String id;
  final double rating;
  final String productId;

  const AddFeedback({this.userName = '', this.feedback = '', this.id = '', this.rating= 0.0, required this.productId});

  @override
  State<AddFeedback> createState() => _AddFeedbackState();
}

class _AddFeedbackState extends State<AddFeedback> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();
  double rating = 0; 
  bool showProgressIndicator = false;

  @override
  void initState() {
    userNameController.text = widget.userName;
    feedbackController.text = widget.feedback;
    rating = widget.rating;
    super.initState();
  }

  @override
  void dispose() {
    userNameController.dispose();
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'addfeedback'.tr,
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20, bottom: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'user'.tr,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              TextField(
                controller: userNameController,
                decoration: InputDecoration(),
              ),
              SizedBox(height: 20),
              Text(
                'feedback'.tr,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              TextField(
                controller: feedbackController,
                decoration: InputDecoration(),
              ),
              SizedBox(height: 20),
              Text(
                'rating'.tr,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              SizedBox(height: 20),
              RatingBar.builder( // Add the star rating input.
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 50,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  setState(() {
                    rating = newRating;
                  });
                },
              ),
              SizedBox(height: 20),
              Container(
                height: 60,
                width: double.infinity,
                child: MaterialButton(
                  onPressed: () async {
                    setState(() {});
                    if (userNameController.text.isEmpty ||
                        feedbackController.text.isEmpty ||
                        rating == 0) { // Check if rating is 0.
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'Oops...',
                        text: 'All fields, including rating, are required!',
                      );
                    } else {
                      final dUser = FirebaseFirestore.instance.collection('feedbacks').doc(widget.id.isNotEmpty ? widget.id : null);

                      String docId = '';
                      if (widget.id.isNotEmpty) {
                        docId = widget.id;
                      } else {
                        docId = dUser.id;
                      }
                      final jsonData = {
                        'userName': userNameController.text,
                        'feedback': feedbackController.text,
                        'rating': rating,
                        'id': docId,
                        'productId': widget.productId,
                      };
                      showProgressIndicator = true;
                      if (widget.id.isEmpty) {
                        await dUser.set(jsonData).then((value) {
                          userNameController.text = '';
                          feedbackController.text = '';
                          showProgressIndicator = false;
                          setState(() {});
                        });
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.success,
                          text: 'Feedback Added Successfully!',
                        );
                      } else {
                        await dUser.update(jsonData).then((value) {
                          userNameController.text = '';
                          feedbackController.text = '';
                          showProgressIndicator = false;
                          setState(() {});
                        });
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.success,
                          text: 'Feedback Updated Successfully!',
                        );
                      }
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.black,
                  child: showProgressIndicator
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          'submit'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
