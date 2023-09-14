import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  final int? unreadCount;

  const MyListTile({
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
    this.unreadCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        onTap: onTap,
        title: Row(
          children: <Widget>[
            Text(text, style: TextStyle(color: Colors.white)),
            if (unreadCount != null && unreadCount! > 0)
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  child: Text(
                    '$unreadCount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
