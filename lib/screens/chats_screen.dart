// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:blue/services/preferences_update.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

// Project imports:
import 'package:blue/screens/settings_screen.dart';
import 'package:blue/widgets/empty_state.dart';
import '../main.dart';
import '../models/user.dart';
import '../widgets/progress.dart';
import './chat_messages_screen.dart';
import './home.dart';

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
    chatUsers = usersRef.get();
    var direct =  PreferencesUpdate().getString('direct');
    directMap = direct == null ? {} : json.decode(direct);
    Timer.periodic(Duration(minutes: 1), (Timer t) {   
      if(this.mounted)
      setState(() {
             var direct =  PreferencesUpdate().getString('direct');
    directMap = direct == null ? {} : json.decode(direct);
        });});
    super.initState();
  }

  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context);
    return chatsList(chatUsers);
  }

  FutureBuilder chatsList(Future<QuerySnapshot> chatUsers) {
    return FutureBuilder(
      future: chatUsers,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Widget> chatUsers = [];
        snapshot.data.docs.forEach((QueryDocumentSnapshot doc) {
          User user = User.fromDocument(doc.data());
          print(user);
         Widget userChat =
      OpenContainer<bool>(
              transitionType: ContainerTransitionType.fadeThrough,
              openBuilder: (BuildContext _, VoidCallback openContainer) {
                return ChatMessagesScreen(peerUser:user);
              },
              onClosed: null,
              tappable: false,
              closedShape: const RoundedRectangleBorder(),
              closedElevation: 0.0,
              closedBuilder: (BuildContext _, VoidCallback openContainer) {
                return chatUserListTile(user,openContainer);});
          chatUsers.add(userChat);
        });
if(chatUsers ==  null)  //TODO check
  return emptyState(context, 'No new Messages','Message Sent',subtitle: 'Any new messages will appear here' );

        return ListView.builder(
          itemBuilder: (_,i){
               return chatUsers[i];
          },
    itemCount: chatUsers.length,
        );
      },
    );
  }

  InkWell chatUserListTile(User user,VoidCallback openContainer) {
    
    return InkWell(onTap: openContainer,
              child: 
             ListTile(
               tileColor:  Theme.of(context).backgroundColor,
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
            
          
      
    );
  }
}
