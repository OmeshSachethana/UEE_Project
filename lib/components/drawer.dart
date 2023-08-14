import 'package:flutter/material.dart';
import 'package:new_app/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignoutTap;

  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSignoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(children: [
        const DrawerHeader(
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: 64,
          ),
        ),
        MyListTile(
          icon: Icons.home,
          text: 'H O M E',
          onTap: () => Navigator.pop(context),
        ),

        //profile
        MyListTile(
            icon: Icons.person, text: "P R O F I L E", onTap: onProfileTap),

        MyListTile(
            icon: Icons.person, text: "L O G O U T", onTap: onSignoutTap),
      ]),
    );
  }
}
