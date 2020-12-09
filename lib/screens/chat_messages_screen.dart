import 'dart:convert';
import 'dart:io';
import '../services/file_storage.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
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
  @override
  _ChatMessagesScreenState createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
 var focusNode = new FocusNode();
  User peerUser;
  String groupChatId;
  Map sendingStateMap = {
    'count': 0,
    'id': {},
    'state': ''
  };
    Map deletingStateMap = {
        'count': 0,
    'lastId': '',
     'state': ''
    };
  Future<QuerySnapshot> chatMessagesFuture;
  TextEditingController messageController = TextEditingController();
  @override
  void dispose() {
        sendingStateMap['id'] = {};
          sendingStateMap['state'] = '';
              sendingStateMap['count'] = 0;
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    print('$sendingStateMap 123d'  );
    var peerUserMap =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    peerUser = peerUserMap['user'];
    if (currentUser.id.hashCode <= peerUser.id.hashCode) {
      groupChatId = '${currentUser.id}-${peerUser.id}';
    } else {
      groupChatId = '${peerUser.id}-${currentUser.id}';
    }
    getChatMessagesFuture();
    super.didChangeDependencies();
  }

  getChatMessagesFuture(){
   setState((){
      chatMessagesFuture = messagesRef
          .doc(groupChatId)
          .collection(groupChatId)
          .orderBy('timestamp', descending: true)
         // .where('hide',isEqualTo: )           TODO 
          .get();
    });
  }

  sendMessage()async {
    if (messageController.text != '') {
        DateTime dateTime = DateTime.now();
        String textMessage =  messageController.text;
      setState(() {
        sendingStateMap['id'][dateTime.toString()] = false;
        sendingStateMap['state'] = 'Sending';
                sendingStateMap['count'] = sendingStateMap['count']+1;
        messageController.clear();
      });
    
     await messagesRef.doc(groupChatId).collection(groupChatId).add({
        'idFrom': currentUser.id,
        'idTo': peerUser.id,
        'timestamp': dateTime,
        'message': textMessage,
        'type': 'text'
      });

           sendingStateMap['id'][dateTime.toString()] = true;
       bool valid = true;
         sendingStateMap['id'].forEach((k,v){
            if(v == false)
            valid = false;
         });
         print(valid);
       
      getChatMessagesFuture();
      Future.delayed(const Duration(milliseconds: 1000), () {    setState(() {
              if( valid){
                   print(sendingStateMap['count']);
          sendingStateMap['state'] = sendingStateMap['count']> 1?'All Sent':'Sent';
          }
      });});
      Future.delayed(const Duration(milliseconds: 5000), () {
  setState(() {
  if( valid){
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
            sendingStateMap['count'] = sendingStateMap['count']+1;
      });
          messagesRef.doc(groupChatId).collection(groupChatId).add({
            'idFrom': currentUser.id,
            'idTo': peerUser.id,
            'timestamp': dateTime,
            'message': value,
            'type': 'gif'
          }).then((_) {
                 sendingStateMap['id'][dateTime.toString()] = true;
                  bool valid = true;
         sendingStateMap['id'].forEach((k,v){
            if(v == false)
            valid = false;
         });
      Future.delayed(const Duration(milliseconds: 5000), () {    setState(() {
        print('assfsz gif');
              if( valid){
                   print(sendingStateMap['count']);
          sendingStateMap['state'] = sendingStateMap['count']> 1?'All Sent':'Sent';
          }
      });});
      Future.delayed(const Duration(milliseconds: 5000), () {
  setState(() {
  if(valid){
        sendingStateMap['id'] = {};
          sendingStateMap['state'] = '';
               sendingStateMap['count'] = 0;
          }
  });
});
            getChatMessagesFuture();
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
                  sendingStateMap['count'] = sendingStateMap['count']+1;
      });
      if (pickedFile != null) {
        image = File(pickedFile.path); // TODO
        String imageId = Uuid().v4();
        final tempDir = await getTemporaryDirectory();
        final path = tempDir.path;
        final Im.Image imageFile = Im.decodeImage(image.readAsBytesSync());
        final compressedImageFile = File('$path/img_$imageId.jpg')
          ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    var imageUri = await FileStorage.upload('chat','chat_$imageId.jpg', compressedImageFile);
  String downloadUrl = imageUri.toString();
        messagesRef.doc(groupChatId).collection(groupChatId).add({
          'idFrom': currentUser.id,
          'idTo': peerUser.id,
          'timestamp': dateTime ,
          'message': downloadUrl,
          'type': 'image'
        });
         sendingStateMap['id'][dateTime.toString()] = true;
                 bool valid = true;
         sendingStateMap['id'].forEach((k,v){
            if(v == false)
            valid = false;
         });
         Future.delayed(const Duration(milliseconds: 1000), () {    setState(() {
              if( valid){
                print(sendingStateMap['count']);
          sendingStateMap['state'] = sendingStateMap['count']> 1?'All Sent':'Sent';
         
          }
      });});
      Future.delayed(const Duration(milliseconds: 5000), () {
  setState(() {
  if( valid){
               sendingStateMap['id'] = {};
          sendingStateMap['state'] = '';
              sendingStateMap['count'] = 0;
          }
  });

});
       getChatMessagesFuture();
      }
    } catch (e) {
      print(e);
    }
  }

  FutureBuilder chatMessages(Future<QuerySnapshot> chatMessagesFuture) {
    return FutureBuilder(
      future: chatMessagesFuture,
      builder: (context, snapshot) {
        Timestamp lastTimestamp = Timestamp(0, 0);
        bool showTime = false;
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Widget> messageItems = [];
        int length = snapshot.data.documents.length;
        int i = 0;
        snapshot.data.docs.forEach((QueryDocumentSnapshot doc) {
          i++;
          Message messageItem = Message.fromDocument(doc.data());
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

                     Text(  sendingStateMap['state'],
                     style: TextStyle(fontSize: 16,color: Theme.of(context).iconTheme.color,
                     fontWeight: FontWeight.w500),
                     ),
                     if(sendingStateMap['state'] == 'Sending')
                    Container(
                      height: 20,
                      width: 20,
                      padding: const EdgeInsets.all(3.0),
                      child: CircularProgressIndicator(
                        
                       strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation(
        Colors.blue
      ),
    ),
    
                    ),
                      if(sendingStateMap['state'] == 'Sent')
                    Container(
                      height: 20,
                      width: 20,
                      child: Icon(Icons.check,
                      color: Colors.blue,
                      size: 20,),),
                   ],
                 ),),
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
            directMap[peerUser.id] = {
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
          if(doc.data()['hide'] != true ||  myText)
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
                              child: Text('Sent on ${date(lastTimestamp.toDate())}, ${DateFormat.jm().format(lastTimestamp.toDate())}'),
                            ),
                            InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                if (myText) {
                                  try {
                                    await messagesRef
                                        .doc(groupChatId)
                                        .collection(groupChatId)
                                        .doc(doc.id)
                                        .delete();
                                    if (messageItem.type == 'image') {
                                    await  FileStorage.delete( messageItem.message);
                                     
                                    }
                                  } catch (e) {
                                    print(e);
                                  }
                                } else {
                                  await messagesRef
                                      .doc(groupChatId)
                                      .collection(groupChatId)
                                      .doc(doc.id)
                                      .set({'hide': true},SetOptions(merge: true));
                                }
                                getChatMessagesFuture();
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
        return ListView.builder(
          itemBuilder: (_, i) {
            return messageItems[i];
          },
          itemCount: messageItems.length,
          reverse: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: header(
          context,
          leadingButton: CupertinoNavigationBarBackButton(),
          actionButton: IconButton(
              icon: Icon(
                Icons.info_outline,
              ),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(ChatInfoScreen.routeName, arguments: {
                  'peerId': peerUser.id,
                  'peerUsername': peerUser.username,
                  'groupChatId': groupChatId,
                });
              }),
          title: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 0, right: 15, bottom: 5, top: 5),
                child: CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(peerUser.photoUrl),
                ),
              ),
              Expanded(
                child: Text(
                  peerUser.displayName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: <Widget>[
              Expanded(child: Container(
                child: chatMessages(chatMessagesFuture))),
              Container(
                color: Theme.of(context).canvasColor,
                padding: EdgeInsets.only(bottom: 5, top: 7, left: 1, right: 1),
                child: Row(
                  children: <Widget>[
                    Container(
                      // height: ,
                      margin:
                          EdgeInsets.only(top: 0, bottom: 4, right: 0, left: 0),
                      child: GestureDetector(
                          child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                FlutterIcons.image_fea,
                                size: 28,
                              )),
                          onTap: sendMedia),
                    ),
                    Container(
                      height: 40,
                      margin:
                          EdgeInsets.only(top: 0, bottom: 4, right: 8, left: 0),
                      child: GestureDetector(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 7.8),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: Theme.of(context).iconTheme.color,
                                    width: 2.2)),
                            child: Icon(
                              FlutterIcons.gif_mco,
                              color: Theme.of(context).iconTheme.color,
                              size: 21,
                            ),
                          ),
                          onTap: sendGIF),
                    ),
                    Expanded(
                      child: Container(
                        // height: 45,
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
                            contentPadding: EdgeInsets.only(top: 8, left: 10),
                            hintText: 'Message',
                            hintStyle: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context)
                                    .iconTheme
                                    .color
                                    .withOpacity(0.8)),
                            fillColor: Theme.of(context).cardColor,
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
            ],
          ),
        ));
  }

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
}
