import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../main.dart';
import './home.dart';
import '../widgets/progress.dart';
import '../models/user.dart';
import './chat_messages_screen.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with AutomaticKeepAliveClientMixin<ChatsScreen> {
  Future<QuerySnapshot> chatUsers;
  Map directMap = {};
  @override
  void initState() {
    chatUsers = usersRef.getDocuments();
    var direct = preferences.getString('direct');
    directMap = direct == null ? {} : json.decode(direct);
    print(directMap);
    super.initState();
  }

  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: (){
        setState(() {
             var direct = preferences.getString('direct');
    directMap = direct == null ? {} : json.decode(direct);
        });
        
        return Future.value();
      },
      child: chatsList(chatUsers));
  }

  FutureBuilder chatsList(Future<QuerySnapshot> chatUsers) {
    return FutureBuilder(
      future: chatUsers,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Container> chatUsers = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          Container userChat = chatUserListTile(user);
          chatUsers.add(userChat);
        });

        return ListView.builder(
          itemBuilder: (_,i){
               return chatUsers[i];
          },
    itemCount: chatUsers.length,
        );
      },
    );
  }

  Container chatUserListTile(User user) {
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
              subtitle: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                   child:   directMap.containsKey(user.id)
                          ? (directMap[user.id]['message'] ==
                                  '${MessageType.gif}'
                              ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(FlutterIcons.play_box_outline_mco,size: 16,
                                  color: Colors.grey,
                                  ),
                                  Text(' GIF')
                                ],
                              ) 
                              : (directMap[user.id]['message'] ==
                                      '${MessageType.image}'
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(FlutterIcons.image_fea,size: 15,
                                  color: Colors.grey,),
                                  Text(' Image')
                                ],
                              ) 
                                  : Text(directMap[user.id]['message'],maxLines: 1,overflow: TextOverflow.ellipsis,)))
                          : Text(user.username,maxLines: 1,),
                    ),
                  ),
                  Text(directMap.containsKey(user.id)
                      ? '${timeago.format(DateTime.parse(directMap[user.id]['time']))}'
                      : ''),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
