import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:blue/services/go_to.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../services/file_storage.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../widgets/header.dart';
import '../models/user.dart';
import '../widgets/send_button.dart';
import '../widgets/progress.dart';
import '../widgets/message.dart';
import './chat_info_screen.dart';
import './gifs_screen.dart';
import 'package:blue/main.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

enum MessageType { image, gif }

class ChatMessagesScreen extends StatefulWidget {
  static const routeName = 'chat-messages';
  final User peerUser;
  ChatMessagesScreen({this.peerUser});
  @override
  _ChatMessagesScreenState createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  var focusNode = new FocusNode();
  String groupChatId;
  Map sendingStateMap = {'count': 0, 'id': {}, 'state': ''};
  Future<QuerySnapshot> chatMessagesFuture;
  TextEditingController messageController = TextEditingController();
  DateTime lastMessageTime;
  bool loading = true;
  List data = [];
  @override
  void dispose() {
    sendingStateMap['id'] = {};
    sendingStateMap['state'] = '';
    sendingStateMap['count'] = 0;
    super.dispose();
  }



  sendMessage() async {
    if (messageController.text != '') {
      DateTime dateTime = DateTime.now();
      String textMessage = messageController.text;
      setState(() {
        sendingStateMap['id'][dateTime.toString()] = false;
        sendingStateMap['state'] = 'Sending';
        sendingStateMap['count'] = sendingStateMap['count'] + 1;
        messageController.clear();
      });

      await messagesRef.doc(groupChatId).collection(groupChatId).add({
        'idFrom': currentUser.id,
        'idTo': widget.peerUser.id,
        'timestamp': dateTime,
        'message': textMessage,
        'type': 'text'
      });

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
    try {
      DateTime dateTime = DateTime.now();

      Navigator.of(context)
          .pushNamed(GIFsScreen.routeName)
          .catchError((e) {})
          .then((value) {
        if (value != null) {
          setState(() {
            sendingStateMap['id'][dateTime.toString()] = false;
            sendingStateMap['state'] = 'Sending';
            sendingStateMap['count'] = sendingStateMap['count'] + 1;
          });
          messagesRef.doc(groupChatId).collection(groupChatId).add({
            'idFrom': currentUser.id,
            'idTo': widget.peerUser.id,
            'timestamp': dateTime,
            'message': value,
            'type': 'gif'
          }).then((_) {
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
      });
    } catch (e) {
      print(e); //TODO
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
        maxHeight: 1080,
        maxWidth: 1080,
      );
      setState(() {
        sendingStateMap['id'][dateTime.toString()] = false;
        sendingStateMap['state'] = 'Sending';
        sendingStateMap['count'] = sendingStateMap['count'] + 1;
      });
      if (pickedFile != null) {
        image = File(pickedFile.path); // TODO
        String imageId = Uuid().v4();
        final tempDir = await getTemporaryDirectory();
        final path = tempDir.path;
        final Im.Image imageFile = Im.decodeImage(image.readAsBytesSync());
        final compressedImageFile = File('$path/img_$imageId.jpg')
          ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
        var imageUri = await FileStorage.upload(
            'chat', 'chat_$imageId.jpg', compressedImageFile);
        String downloadUrl = imageUri.toString();
        messagesRef.doc(groupChatId).collection(groupChatId).add({
          'idFrom': currentUser.id,
          'idTo': widget.peerUser.id,
          'timestamp': dateTime,
          'message': downloadUrl,
          'type': 'image'
        });
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
    } catch (e) {
      print(e);
    }
  }


  @override
  void initState() {
       if (currentUser.id.hashCode <= widget.peerUser.id.hashCode) {
      groupChatId = '${currentUser.id}-${widget.peerUser.id}';
    } else {
      groupChatId = '${widget.peerUser.id}-${currentUser.id}';
    }
    print('dd');
    
    // getMessages();
    super.initState();
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
                  'peerId': widget.peerUser.id,
                  'peerUsername': widget.peerUser.username,
                  'groupChatId': groupChatId,
                  'peerImageUrl': widget.peerUser.photoUrl,
                  'peerName': widget.peerUser.displayName,
                });
              }),
          title: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  GoTo().profileScreen(context, widget.peerUser.id);
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 0, right: 15, bottom: 5, top: 5),
                  child: CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(widget.peerUser.photoUrl),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget.peerUser.displayName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: Theme.of(context).backgroundColor,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(child: ChatMessages(sendingStateMap,widget.peerUser.id,groupChatId)),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: new BackdropFilter(
                      filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        color: Theme.of(context).backgroundColor == Colors.white
                            ? Colors.grey.shade200.withOpacity(0.5)
                            : Colors.grey.shade700.withOpacity(0.5),
                        padding: EdgeInsets.only(
                            bottom: 5, top: 7, left: 1, right: 1),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: GestureDetector(
                                  child: Container(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(
                                        FluentIcons.image_24_filled,
                                        size: 32,
                                        color: Colors.deepOrange,
                                      )),
                                  onTap: sendMedia),
                            ),
                            Container(
                              height: 40,
                              child: GestureDetector(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      FluentIcons.gif_24_filled,
                                      size: 34,
                                      color: Colors.red,
                                    ),
                                  ),
                                  onTap: sendGIF),
                            ),
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
                                      borderRadius: BorderRadius.circular(15),
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


}


class ChatMessages extends StatefulWidget {
  ChatMessages(this.sendingStateMap,this.peerUserId,this.groupChatId,);

    final Map sendingStateMap;
      final String  peerUserId;
      final String groupChatId;

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
    String date(DateTime tm) {
    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);
    String month;
    switch (tm.month) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }
    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1) {
      return "Today";
    } else if (difference.compareTo(twoDay) < 1) {
      return "Yesterday";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "Monday";
        case 2:
          return "Tuesday";
        case 3:
          return "Wednesday";
        case 4:
          return "Thurdsday";
        case 5:
          return "Friday";
        case 6:
          return "Saturday";
        case 7:
          return "Sunday";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month';
    } else {
      return '${tm.day} $month ${tm.year}';
    }
    return "";
  }
   List data  = [];
   bool loading  = true;
   @override
  void initState() {
    //  getMessages();
    super.initState();
  }
  
  // getMessages() async {
  //  var _cachedMessages = await messagesRef
  //       .doc(widget.groupChatId)
  //       .collection(widget.groupChatId)
  //       .orderBy('timestamp', descending: true) //         TODO
  //       .get(GetOptions(source: Source.cache));
  //       print(_cachedMessages.docs.length);
  //   _cachedMessages.docs.forEach((DocumentSnapshot doc) {
  //     data.add([doc.id,doc.data()]);
  //     //  messages.add(doc);
  //   });
  //   setState(() {
  //     loading = false;
  //   });
  //   if(data.length != 0){
  //   print(data.first[1]['timestamp']);
  //   addMessagesStream(data.first[1]['timestamp']);
  //   }
  // }

  addMessagesStream() async {
    Stream<QuerySnapshot> _snaps = messagesRef
        .doc(widget.groupChatId)
        .collection(widget.groupChatId)
        // .where('timestamp', isGreaterThan: dateTime)
        .orderBy('timestamp', descending: false)
        .snapshots();
        var _cachedMessages = messagesRef
        .doc(widget.groupChatId)
        .collection(widget.groupChatId)
        .orderBy('timestamp', descending: true) //         TODO
        .get(GetOptions(source: Source.cache)).asStream();
  // _snaps.listen((event) {
  //     event.docChanges.forEach((change) {
  //       print(change.doc.data());
  //       if (change.type == DocumentChangeType.added) {
  //         setState(() {
  //       data.add([change.doc.id,change.doc.data()]);
  //           // newMessages.add(change.doc);
  //         });
          
  //       }
  //     });
  //   });
    
  }

  @override
  Widget build(BuildContext context) {
      Timestamp lastTimestamp = Timestamp(0, 0);
      setState(() {
        
      });
    bool showTime = false;
    if (data == null) {
      return circularProgress();
    }
    List<Widget> messageItems = [];
    int length = data.length;
    if (length == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: emptyState(context, 'Say Hi!', "Welcome")),
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
    data.forEach(( doc) {
      i++;
      Message messageItem = Message.fromDocument(doc[1]);
      if (i == 1) {
        messageItems.add(Visibility(
          visible: widget.sendingStateMap['id'] != {},
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 8),
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.sendingStateMap['state'],
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).iconTheme.color,
                      fontWeight: FontWeight.w500),
                ),
                if (widget.sendingStateMap['state'] == 'Sending')
                  Container(
                    height: 20,
                    width: 20,
                    padding: const EdgeInsets.all(3.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                    ),
                  ),
                if (widget.sendingStateMap['state'] == 'Sent')
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
        var direct = preferences.getString('direct');
        Map directMap = direct == null ? {} : json.decode(direct);
        if (messageItem.type == 'image')
          lastMessage = '${MessageType.image}';
        else if (messageItem.type == 'gif')
          lastMessage = '${MessageType.gif}';
        else
          lastMessage = '${messageItem.message}';
        directMap[widget.peerUserId] = {/////////////////////////////////
          'seen': true,
          'message': lastMessage,
          'time': messageItem.timestamp.toDate().toString(),
          'mine': messageItem.idFrom == currentUser.id ? true : false,
        };
        direct = json.encode(directMap);
        preferences.setString('direct', direct);
      }
      showTime = 30 <
          lastTimestamp
              .toDate()
              .difference(messageItem.timestamp.toDate())
              .inMinutes;
      if (showTime)
        messageItems.add(Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(
                child: Text(
              '${date(lastTimestamp.toDate())}, ${DateFormat.jm().format(lastTimestamp.toDate())}',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ))));
      bool myText = currentUser.id == messageItem.idFrom;
      if (doc[1]['hide'] != true || myText)
        messageItems.add(InkWell(
            //TODO
            onLongPress: () {
              FocusScope.of(context).unfocus();
              showDialog(
                  context: context,
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
                              'Sent on ${date(lastTimestamp.toDate())}, ${DateFormat.jm().format(lastTimestamp.toDate())}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              if (myText) {
                                try {
                                  await messagesRef
                                      .doc(widget.groupChatId)
                                      .collection(widget.groupChatId)
                                      .doc(doc[0])
                                      .delete();
                                  if (messageItem.type == 'image') {
                                    await FileStorage.delete(//TODO
                                        messageItem.message);
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              } else {
                                await messagesRef
                                    .doc(widget.groupChatId)
                                    .collection(widget.groupChatId)
                                    .doc(doc[0])
                                    .set({'hide': true},
                                        SetOptions(merge: true));
                              }
                              await messagesRef.doc(widget.groupChatId).collection(widget.groupChatId).doc(doc[0]).delete();
                               setState(() {
                  data.remove(doc);
                });
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                decoration: new BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
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
                        ],
                      )));
            },
            child: messageItem));

      lastTimestamp = messageItem.timestamp;
      if (length == i) {
        messageItems.add(Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(
                child: Text(
              '${date(lastTimestamp.toDate())}, ${DateFormat.jm().format(lastTimestamp.toDate())}',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ))));
      }
    });
    return Scrollbar(
      thickness: 4,
      radius: Radius.circular(5),
      child: ListView.builder(
        padding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 70),
        itemBuilder: (_, i) {
          return messageItems[i];
        },
        itemCount: messageItems.length,
        reverse: true,
      ),
    );
  }
}