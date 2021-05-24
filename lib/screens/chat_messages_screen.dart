// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

// Flutter imports:
import 'package:blue/services/boxes.dart';
import 'package:blue/services/functions.dart';
import 'package:blue/services/graphql.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/go_to.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/progress.dart';
import '../models/user.dart';
import '../services/file_storage.dart';
import '../widgets/header.dart';
import '../widgets/message.dart';
import '../widgets/progress.dart';
import '../widgets/send_button.dart';
import './chat_info_screen.dart';
import './gifs_screen.dart';

enum MessageType { image, gif }

class ChatMessagesScreen extends StatefulWidget {
  static const routeName = 'chat-messages';
  final User peerUser;
  final int convId;
  ChatMessagesScreen({this.peerUser, this.convId});
  @override
  _ChatMessagesScreenState createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  var focusNode = new FocusNode();
  bool first = false;
  dynamic data = [];
  Map sendingStateMap = {'count': 0, 'id': {}, 'state': ''};
  TextEditingController messageController = TextEditingController();
  DateTime lastMessageTime;
  bool loading = true;
  int convId;
  @override
  void dispose() {
    sendingStateMap['id'] = {};
    sendingStateMap['state'] = '';
    sendingStateMap['count'] = 0;
    super.dispose();
  }

  sendMessage() async {
    if (true) {
      DateTime dateTime = DateTime.now();
      String textMessage = messageController.text;
      setState(() {
        sendingStateMap['id'][dateTime.toString()] = false;
        sendingStateMap['state'] = 'Sending';
        sendingStateMap['count'] = sendingStateMap['count'] + 1;
        messageController.clear();
      });
      print('convId : $convId');
      await Hasura.insertMessage(
          widget.peerUser.userId, convId, 'text', textMessage, context);

      sendingStateMap['id'][dateTime.toString()] = true;
      bool valid = true;
      sendingStateMap['id'].forEach((k, v) {
        if (v == false) valid = false;
      });
      print(valid);
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          if (valid) {
            print(sendingStateMap['count']);
            sendingStateMap['state'] =
                sendingStateMap['count'] > 1 ? 'All Sent' : 'Sent';
          }
        });
      });
      Future.delayed(const Duration(milliseconds: 5000), () {
        setState(() {
          if (valid) {
            sendingStateMap['id'] = {};
            sendingStateMap['state'] = '';
            sendingStateMap['count'] = 0;
          }
        });
      });
    }
  }

  sendGIF() async {
    FocusScope.of(context).unfocus();

    DateTime dateTime = DateTime.now();

    var value = await Navigator.of(context).pushNamed(GIFsScreen.routeName);

    if (value == null) {
      return null;
    }
    if (value != null) {
      setState(() {
        sendingStateMap['id'][dateTime.toString()] = false;
        sendingStateMap['state'] = 'Sending';
        sendingStateMap['count'] = sendingStateMap['count'] + 1;
      });
      await Hasura.insertMessage(
              widget.peerUser.userId, convId, 'gif', value.toString(), context)
          .then((_) {
        sendingStateMap['id'][dateTime.toString()] = true;
        bool valid = true;
        sendingStateMap['id'].forEach((k, v) {
          if (v == false) valid = false;
        });
        Future.delayed(const Duration(milliseconds: 5000), () {
          setState(() {
            print('assfsz gif');
            if (valid) {
              print(sendingStateMap['count']);
              sendingStateMap['state'] =
                  sendingStateMap['count'] > 1 ? 'All Sent' : 'Sent';
            }
          });
        });
        Future.delayed(const Duration(milliseconds: 5000), () {
          setState(() {
            if (valid) {
              sendingStateMap['id'] = {};
              sendingStateMap['state'] = '';
              sendingStateMap['count'] = 0;
            }
          });
        });
      });
    }

    return true;
  }

  _send(Function fn) async {
    if (data.isEmpty) {
      if (convId == null) {
        convId = await Hasura.insertConversation(widget.peerUser.userId);
      }

      setState(() {
        focusNode = new FocusNode();
        first = false;
        data = [];
        sendingStateMap = {'count': 0, 'id': {}, 'state': ''};

        lastMessageTime = null;
        loading = true;
      });
    }
    bool t = await fn();
    if (t != true) {
      setState(() {
        loading = false;
      });

      return;
    }
    if (data.isEmpty) {
      addMessages();
      setState(() {
        dataEmpty = false;
      });
    }
  }

  sendMedia() async {
    FocusScope.of(context).unfocus();
    try {
      DateTime dateTime = DateTime.now();
      File image;
      var picker = ImagePicker();
      var pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        maxHeight: 720,
        maxWidth: 720,
      );
      if (pickedFile == null) {
        return null;
      }
      setState(() {
        sendingStateMap['id'][dateTime.toString()] = false;
        sendingStateMap['state'] = 'Sending';
        sendingStateMap['count'] = sendingStateMap['count'] + 1;
      });
      if (pickedFile != null) {
        image = File(pickedFile.path);
        print('file opened');
        String downloadUrl = await FileStorage.uploadImage(
            convId.toString(), image,
            bucket: 'chat-messages');

        await Hasura.insertMessage(
            widget.peerUser.userId, convId, 'image', downloadUrl, context);
        sendingStateMap['id'][dateTime.toString()] = true;
        bool valid = true;
        sendingStateMap['id'].forEach((k, v) {
          if (v == false) valid = false;
        });
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            if (valid) {
              print(sendingStateMap['count']);
              sendingStateMap['state'] =
                  sendingStateMap['count'] > 1 ? 'All Sent' : 'Sent';
            }
          });
        });
        Future.delayed(const Duration(milliseconds: 5000), () {
          setState(() {
            if (valid) {
              sendingStateMap['id'] = {};
              sendingStateMap['state'] = '';
              sendingStateMap['count'] = 0;
            }
          });
        });
      }
      return true;
    } catch (e) {
      print(e);
    }
  }

  getConvId() async {
    convId = await Hasura.getConvId(widget.peerUser.userId);
  }

  GraphQLClient _client;
  @override
  void initState() {
    convId = widget.convId;

    addMessages();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _client = GraphQLProvider.of(context).value;
    // });
    super.initState();
  }

  Container sendButton({Function sendFunction}) {
    return Container(
      margin: EdgeInsets.only(right: 4, left: 0),
      height: 41,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
      child: IconButton(
        icon: Icon(
          FlutterIcons.send_fea,
          color: Colors.white,
          size: 26,
        ),
        onPressed: () async {
          if (data.isEmpty) {
            if (convId == null)
              convId = await Hasura.insertConversation(widget.peerUser.userId);
            setState(() {
              focusNode = new FocusNode();
              first = false;
              data = [];
              sendingStateMap = {'count': 0, 'id': {}, 'state': ''};

              lastMessageTime = null;
              loading = true;
            });
          }
          await sendFunction();
          if (data.isEmpty) {
            addMessages();
            setState(() {
              dataEmpty = false;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: header(
          context,
          elevation: 0.5,
          leadingButton: CupertinoNavigationBarBackButton(),
          actionButton: IconButton(
              icon: Icon(
                FluentIcons.info_24_regular,
              ),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(ChatInfoScreen.routeName, arguments: {
                  'peerId': widget.peerUser.userId,
                  'peerUsername': widget.peerUser.username,
                  'peerImageUrl': widget.peerUser.avatarUrl ??
                      "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744",
                  'peerName': widget.peerUser.name,
                });
              }),
          title: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  GoTo().profileScreen(context, widget.peerUser.userId);
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 0, right: 15, bottom: 5, top: 5),
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(widget
                            .peerUser.avatarUrl ??
                        "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget.peerUser.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(bottom: Platform.isIOS ? 20 : 0),
          color: Theme.of(context).backgroundColor,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Container(child: chatMessages()),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: new BackdropFilter(
                      filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        color: Theme.of(context).backgroundColor == Colors.white
                            ? Colors.grey.shade200.withOpacity(0.5)
                            : Colors.grey.shade700.withOpacity(0.5),
                        padding: EdgeInsets.only(
                          bottom: 5,
                          top: 5,
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: GestureDetector(
                                  child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context)
                                                      .iconTheme
                                                      .color ==
                                                  Colors.black
                                              ? Colors.white
                                              : Colors.grey.shade100
                                                  .withOpacity(0.2)),
                                      margin:
                                          EdgeInsets.only(left: 5, right: 3),
                                      child: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: Icon(
                                          FluentIcons.image_24_regular,
                                          size: 32,
                                          color: Theme.of(context)
                                                      .iconTheme
                                                      .color ==
                                                  Colors.black
                                              ? Colors.grey.shade700
                                              : Colors.white.withOpacity(0.8),
                                        ),
                                      )),
                                  onTap: () {
                                    _send(sendMedia);
                                  }),
                            ),
                            GestureDetector(
                                child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            Theme.of(context).iconTheme.color ==
                                                    Colors.black
                                                ? Colors.white
                                                : Colors.grey.shade100
                                                    .withOpacity(0.2)),
                                    margin: EdgeInsets.only(right: 5),
                                    child: SizedBox(
                                      height: 41,
                                      width: 41,
                                      child: Icon(
                                        FluentIcons.gif_24_regular,
                                        size: 32,
                                        color:
                                            Theme.of(context).iconTheme.color ==
                                                    Colors.black
                                                ? Colors.grey.shade700
                                                : Colors.white.withOpacity(0.8),
                                      ),
                                    )),
                                onTap: () {
                                  _send(sendGIF);
                                }),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(bottom: 2),
                                child: TextField(
                                  focusNode: focusNode,
                                  controller: messageController,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).iconTheme.color),
                                  maxLines: 4,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.only(top: 8, left: 10),
                                    hintText: 'Message',
                                    hintStyle: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .iconTheme
                                            .color
                                            .withOpacity(0.8)),
                                    fillColor: Theme.of(context).canvasColor,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide(
                                        width: 0,
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        width: 0,
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            sendButton(sendFunction: sendMessage)
                          ],
                        ),
                      ),
                    )),
              )
            ],
          ),
        ));
  }

  addMessages() async {
    if (convId == null) {
      await getConvId();
    }
    usersRef.snapshots();
    List messages = await Hasura.getMessages(convId);
    if (messages.length == 0) {
      first = true;
    }
    setState(() {
      data = messages.reversed;
      loading = false;
    });
  }

  bool dataEmpty;
  chatMessages() {
    DateTime firstTime;
    DateTime lastTimestamp = DateTime.fromMicrosecondsSinceEpoch(0);
    bool showTime = false;
    if (loading) {
      return circularProgress();
    }
    List<Widget> messageItems = [];
    int length = data.length;
    if (dataEmpty == null) {
      dataEmpty = data.isEmpty;
    }
    if (dataEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: Center()),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 80),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue.withOpacity(0.24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMMUNITY RULES',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '😊 Be friendly and polite\n🙈 Keep it safe for work/appropriate for all ages\n🚫 Offensive behaviour, Spamming, harassment or bullying is forbidden\n👮‍♂️ Users who violate the rules will be blocked',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w400, height: 1.7),
                )
              ],
            ),
          ),
        ],
      );
    }
    int i = 0;
    data.forEach((doc) {
      i++;
      Message messageItem = Message.fromDocument(doc);
      if (i == 1) {
        messageItems.add(Visibility(
          visible: sendingStateMap['id'] != {},
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 8),
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  sendingStateMap['state'] == 'Sending'
                      ? '  ...'
                      : sendingStateMap['state'],
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).iconTheme.color.withOpacity(0.8),
                      fontWeight: FontWeight.w400),
                ),
                if (sendingStateMap['state'] == 'Sending')
                  Container(
                    height: 16,
                    width: 16,
                    padding: const EdgeInsets.all(3.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                    ),
                  ),
                if (sendingStateMap['state'] == 'Sent')
                  Container(
                    height: 20,
                    width: 20,
                    child: Icon(
                      Icons.check,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ));
        String lastMessage = '';
        var direct = PreferencesUpdate().getString('direct');
        Map directMap = direct == null ? {} : json.decode(direct);
        if (messageItem.type == 'image')
          lastMessage = '${MessageType.image}';
        else if (messageItem.type == 'gif')
          lastMessage = '${MessageType.gif}';
        else
          lastMessage = '${messageItem.message}';
        directMap[widget.peerUser.id.toString()] = {
          //TODO
          ///////////////////////////////
          'seen': true,
          'message': lastMessage,
          'time': messageItem.timestamp.toString(),
          'mine': messageItem.idFrom == currentUser.id ? true : false,
        };
        direct = json.encode(directMap);
        PreferencesUpdate().updateString('direct', direct);
      }
      showTime = 30 < lastTimestamp.difference(messageItem.timestamp).inMinutes;
      if (showTime)
        messageItems.add(Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(
                child: Text(
              '${Functions().date(lastTimestamp.toLocal())}, ${DateFormat.jm().format(lastTimestamp.toLocal())}',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ))));
      bool myText = currentUser.id == messageItem.idFrom;
      if (doc['hide'] != true || myText)
        messageItems.add(messageTransform(messageItem, myText, i));
      print(lastTimestamp.toString());
      lastTimestamp = messageItem.timestamp;
      if (firstTime == null) {
        firstTime = lastTimestamp;
      }
      if (length == i) {
        print(lastTimestamp.toString());
        messageItems.add(Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(
                child: Text(
              '${Functions().date(lastTimestamp.toLocal())}, ${DateFormat.jm().format(lastTimestamp.toLocal())}',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ))));
      }
    });
    print("lastt $lastTimestamp");
    return Scrollbar(
      thickness: 2,
      radius: Radius.circular(5),
      child: ListView.builder(
        padding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 70),
        itemBuilder: (_, i) {
          if (i == 0) {
            if (messageItems == []) {
              messageItems = [Container()];
            }

            return messageItems[0];
          }
          if (i == 1) {
            return GraphQLProvider(
                client: Config.initailizeClient(),
                child: CacheProvider(
                    child: Subscription(
                  options: SubscriptionOptions(document: gql("""subscription{
 messages(where:{_and:[{conv_id:{_eq:${widget.convId}}},{created_at:{_gt:"$firstTime"}}]},){
     created_at
     data
     msg_id
     sender_id
     type
     deleted_by_sender
   }
 }""")),
                  builder: (result) {
                    if (result.data == null) return Container();
                    print('subs: $result');
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, j) {
                        return messageTransform(
                            Message.fromDocument(
                              result.data['messages'][j],
                            ),
                            currentUser.id ==
                                result.data['messages'][j]['sender_id'],
                            i);
                      },
                      itemCount: result.data['messages'].length,
                    );
                  },
                )));
          }
          return messageItems[i - 1];
        },
        itemCount: messageItems.length + 1,
        reverse: true,
      ),
    );
  }

  messageTransform(Message messageItem, bool myText, int index) {
    return InkWell(
        //TODO
        onLongPress: () {
          FocusScope.of(context).unfocus();
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Sent on ${Functions().date(messageItem.timestamp.toLocal())}, ${DateFormat.jm().format(messageItem.timestamp.toLocal())}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          if (myText) {
                            if (messageItem.deletedBySender == false) {
                              await Hasura.deleteMessage(messageItem.id);
                            } else {
                              await Hasura.messageDeleteForMe(
                                  messageItem.id, true);
                            }
                          } else {
                            if (messageItem.deletedBySender == true) {
                              await Hasura.deleteMessage(messageItem.id);
                            } else {
                              await Hasura.messageDeleteForMe(
                                  messageItem.id, false);
                            }
                          }
                          setState(() {
                            data = null;
                            addMessages();
                            loading = true;
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            decoration: new BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10.0,
                                  offset: const Offset(0.0, 10.0),
                                ),
                              ],
                            ),
                            child: Container(
                              height: 20,
                              child: Center(
                                  child: Text(
                                myText
                                    ? 'Delete this Message'
                                    : 'Delete for me',
                                style: TextStyle(fontSize: 16),
                              )),
                            )),
                      ),
                      Divider(
                        color: Theme.of(context).cardColor,
                        height: 1,
                        thickness: 1,
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            decoration: new BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10.0,
                                  offset: const Offset(0.0, 10.0),
                                ),
                              ],
                            ),
                            child: Container(
                              height: 20,
                              child: Center(
                                  child: Text(
                                'Cancel',
                                style: TextStyle(fontSize: 16),
                              )),
                            )),
                      ),
                    ],
                  )));
        },
        child: messageItem);
  }
}
