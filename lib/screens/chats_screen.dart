import 'package:flutter/material.dart';
import './home.dart';
import '../widgets/progress.dart';
import '../models/user.dart';
import './chat_messages_screen.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with AutomaticKeepAliveClientMixin<ChatsScreen> {
  Future<QuerySnapshot> chatUsers;
  @override
  void initState() {
    chatUsers = usersRef.getDocuments();
    super.initState();
  }

  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context);
    return chatsList(chatUsers);
  }
}

FutureBuilder chatsList(Future<QuerySnapshot> chatUsers) {
  return FutureBuilder(
    future: chatUsers,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return circularProgress();
      }
      List<ChatUserListTile> chatUsers = [];
      snapshot.data.documents.forEach((doc) {
        User user = User.fromDocument(doc);
        ChatUserListTile userChat = ChatUserListTile(user);
        chatUsers.add(userChat);
      });
      return ListView(
        children: chatUsers,
      );
    },
  );
}

class ChatUserListTile extends StatelessWidget {
  final User user;
  ChatUserListTile(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ChatMessagesScreen.routeName,
                  arguments: {'user': user});
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                user.username,
              ),
            ),
          )
        ],
      ),
    );
  }
}