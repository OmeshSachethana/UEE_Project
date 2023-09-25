import 'package:flutter/material.dart';
import 'package:new_app/pages/exchange/exchanges_widget.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ExchangesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loggedInUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow
        leading: BackButton(color: Colors.black), // Use BackButton widget
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: ExchangesWidget(loggedInUserEmail: loggedInUserEmail),
      ),
    );
  }
}
