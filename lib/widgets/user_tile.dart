import 'package:blue/models/user.dart';
import 'package:blue/screens/profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final User user;
  UserTile(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id,username: user.username),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.black87),
              ),
            ),
          )
        ],
      ),
    );
  }
}
showProfile(BuildContext context, {String profileId,String username}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileScreen(
        profileId: profileId,
        profileUsername: username,
      ),
    ),
  );
}