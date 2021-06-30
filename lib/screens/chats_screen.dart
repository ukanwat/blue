// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

// Project imports:
import 'package:blue/screens/settings_screen.dart';
import 'package:blue/services/graphql.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/empty_dialog.dart';
import 'package:blue/widgets/empty_state.dart';
import '../main.dart';
import '../models/user.dart';
import '../services/boxes.dart';
import '../widgets/progress.dart';
import './chat_messages_screen.dart';
import './home.dart';

class ChatsScreen extends StatefulWidget {
  final bool archived;
  ChatsScreen(this.archived, Key key) : super(key: key);
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
    dynamic data = await Hasura.getConversations(widget.archived);
    int i = 0;
    data.forEach((doc) {
      int convId = doc['conv_id'];

      if (doc['user1']['user_id'] == Boxes.currentUserBox.get('user_id')) {
        doc = doc['user2'];
      } else {
        doc = doc['user1'];
      }
      User user = User.fromDocument({
        'avatar_url': doc['avatar_url'],
        'user_id': doc['user_id'],
        'username': doc['username'],
        'name': doc['name']
      });
      Widget userChat = OpenContainer<bool>(
          transitionType: ContainerTransitionType.fadeThrough,
          openBuilder: (BuildContext _, VoidCallback openContainer) {
            return ChatMessagesScreen(
              peerUser: user,
              convId: convId,
            );
          },
          onClosed: null,
          tappable: true,
          closedShape: const RoundedRectangleBorder(),
          closedColor: Theme.of(context).backgroundColor,
          closedBuilder: (BuildContext _, VoidCallback openContainer) {
            return chatUserListTile(user, openContainer, i);
          });
      chatUsers.add(userChat);
      i++;
    });
    if (chatUsers == null || chatUsers == []) //TODO check
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
        : chatUsers.length == 0
            ? emptyState(context, 'Empty!', 'Message Sent',
                subtitle:
                    '${widget.archived ? 'Archived' : 'New'} Chats will appear here')
            : ListView.builder(
                itemCount:
                    widget.archived ? chatUsers.length + 1 : chatUsers.length,
                itemBuilder: (context, i) {
                  if (i == 0 && widget.archived) {
                    return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Text(
                          'Archived Chats',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).iconTheme.color),
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.3))),
                        ));
                  }
                  return chatUsers[widget.archived ? i - 1 : i];
                });
  }

  InkWell chatUserListTile(User user, VoidCallback openContainer, int i) {
    return InkWell(
      onTap: openContainer,
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.horizontal,
        secondaryBackground: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                widget.archived ? 'Unarchive chat' : 'Archive chat',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.archived ? Colors.greenAccent : Colors.red),
                child: Icon(
                  FluentIcons.archive_24_filled,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        background: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.archived ? Colors.greenAccent : Colors.red),
                child: Icon(
                  FluentIcons.archive_24_filled,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.archived ? 'Unarchive chat' : 'Archive chat',
                style: TextStyle(fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
        onDismissed: (DismissDirection d) {
          setState(() {
            chatUsers.removeAt(i - 1);
          });
          Hasura.hideConversation(user.userId, widget.archived);
        },
        child: ListTile(
          // onLongPress: () {
          //   showDialog(
          //       context: context,
          //       builder: (ctx) {
          //         return EmptyDialog(Column(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             InkWell(
          //               onTap: () {
          //                 Navigator.of(context).pop();
          //                 setState(() {
          //                   chatUsers.removeAt(i - 1);
          //                 });
          //                 // Hasura.hideConversation(user.userId);
          //               },
          //               child: Container(
          //                 height: 15,
          //                 child: Text('Remove from View'),
          //               ),
          //             ),
          //           ],
          //         ));
          //       });
          // },
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
      ),
    );
  }
}
