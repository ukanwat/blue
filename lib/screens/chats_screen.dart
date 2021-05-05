// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:blue/services/graphql.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/empty_dialog.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

// Project imports:
import 'package:blue/screens/settings_screen.dart';
import 'package:blue/widgets/empty_state.dart';
import '../main.dart';
import '../models/user.dart';
import '../widgets/progress.dart';
import './chat_messages_screen.dart';
import './home.dart';
import '../services/boxes.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with AutomaticKeepAliveClientMixin<ChatsScreen> {
  Map directMap = {};
  List<Widget> chatUsers = [];
  bool loading = true;
  bool empty = false;
  GraphQLClient _client;
  @override
  void initState() {
    // Timer.periodic(Duration(minutes: 1), (Timer t) {
    //   if(this.mounted)
    //   setState(() {
    //          var direct =  PreferencesUpdate().getString('direct');
    // directMap = direct == null ? {} : json.decode(direct);
    //     });});
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _client = GraphQLProvider.of(context).value;
    // });
    getUserTiles();
    super.initState();
  }

  getUserTiles() async {
    dynamic data = await Hasura.getConversations();
    int i = 0;
    data.forEach((doc) {
      int convId = doc['conv_id'];
      print('convId: $convId - ${Hasura.getUserId()}');

      if (doc['user1']['user_id'] == Boxes.currentUserBox.get('user_id')) {
        doc = doc['user2'];
      } else {
        doc = doc['user1'];
      }
      print(doc);
      User user = User.fromDocument({
        'avatar_url': doc['avatar_url'],
        'id': doc['user_id'],
        'username': doc['username'],
        'name': doc['name']
      });
      print(user);
      Widget userChat = OpenContainer<bool>(
          transitionType: ContainerTransitionType.fadeThrough,
          openBuilder: (BuildContext _, VoidCallback openContainer) {
            return ChatMessagesScreen(
              peerUser: user,
              convId: convId,
            );
          },
          onClosed: null,
          tappable: false,
          closedShape: const RoundedRectangleBorder(),
          closedColor: Theme.of(context).backgroundColor,
          closedBuilder: (BuildContext _, VoidCallback openContainer) {
            return chatUserListTile(user, openContainer, i);
          });
      chatUsers.add(userChat);
      i++;
    });
    if (chatUsers == null) //TODO check
      setState(() {
        loading = false;
        empty = true;
      });

    setState(() {
      loading = false;
    });
  }

  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context);
    return loading
        ? circularProgress()
        : empty
            ? emptyState(context, 'No new Messages', 'Message Sent',
                subtitle: 'Any new messages will appear here')
            : ListView.builder(
                itemCount: chatUsers.length,
                itemBuilder: (context, i) {
                  return chatUsers[i];
                });
  }

  InkWell chatUserListTile(User user, VoidCallback openContainer, int i) {
    return InkWell(
      onTap: openContainer,
      child: ListTile(
        onLongPress: () {
          showDialog(
              context: context,
              builder: (ctx) {
                return EmptyDialog(Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          print(i);
                          chatUsers.removeAt(i - 1);
                        });
                        // Hasura.hideConversation(user.userId);
                      },
                      child: Container(
                        height: 15,
                        child: Text('Remove from View'),
                      ),
                    ),
                  ],
                ));
              });
        },
        tileColor: Theme.of(context).backgroundColor,
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(user.avatarUrl ??
              "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: directMap.containsKey(user.id)
                    ? (directMap[user.id]['message'] == '${MessageType.gif}'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                FlutterIcons.play_box_outline_mco,
                                size: 16,
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
                                  Icon(
                                    FlutterIcons.image_fea,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                  Text(' Image')
                                ],
                              )
                            : Text(
                                directMap[user.id]['message'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )))
                    : Text(
                        user.username,
                        maxLines: 1,
                      ),
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
