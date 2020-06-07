import 'dart:io';

import 'package:blue/screens/home.dart';
import 'package:blue/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/header.dart';
import '../models/user.dart';
import '../widgets/send_button.dart';
import '../widgets/progress.dart';
import '../widgets/message.dart';
import './chat_info_screen.dart';
import './gifs_screen.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

class ChatMessagesScreen extends StatefulWidget {
  static const routeName = 'chat-messages';
  @override
  _ChatMessagesScreenState createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  User peerUser;
  String groupChatId;
  Future<QuerySnapshot> chatMessagesFuture;
  TextEditingController messageController = TextEditingController();
  @override
  void didChangeDependencies() {
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

  getChatMessagesFuture() {
    setState(() {
      chatMessagesFuture = messagesRef
          .document(groupChatId)
          .collection(groupChatId).orderBy('timestamp',descending: false)
          
          .getDocuments();
    });
  }

  sendMessage() {
    messagesRef.document(groupChatId).collection(groupChatId).add({
      'idFrom': currentUser.id,
      'idTo': peerUser.id,
      'timestamp': DateTime.now(),
      'message': messageController.text,
      'type': 'text'
    });
    messageController.clear();
    getChatMessagesFuture();
  }
  sendGIF() async{
      Navigator.of(context).pushNamed(GIFsScreen.routeName).catchError((e){
      
      }).
      then((value){
      messagesRef.document(groupChatId).collection(groupChatId).add({
      
      'idFrom': currentUser.id,
      'idTo': peerUser.id,
      'timestamp': DateTime.now(),
      'message': value,
      'type': 'image'
    }).then((_){
       getChatMessagesFuture();
    });

      });
     
  }
  sendMedia() async {
    File image;
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
    String imageId = Uuid().v4();
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final Im.Image imageFile = 
        Im.decodeImage(image.readAsBytesSync());
    final compressedImageFile = File('$path/img_$imageId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
      StorageUploadTask uploadTask =
        storageRef.child("chat_$imageId.jpg").putFile(compressedImageFile ,StorageMetadata(contentType: 'jpg'));
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    messagesRef.document(groupChatId).collection(groupChatId).add({
      
      'idFrom': currentUser.id,
      'idTo': peerUser.id,
      'timestamp': DateTime.now(),
      'message': downloadUrl,
      'type': 'image'
    });

    getChatMessagesFuture();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context,
            leadingButton: CupertinoNavigationBarBackButton(),
            actionButton:
                IconButton(icon: Icon(Icons.info_outline,color: Colors.black,), onPressed: (){
                  Navigator.of(context).pushNamed(ChatInfoScreen.routeName,arguments: {'peerId':peerUser.id});
                }),
            title: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(peerUser.photoUrl),
                  ),
                ),
                Text(
                  peerUser.displayName,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            )),
        body: Column(
          children: <Widget>[
            Expanded(child: chatMessages(chatMessagesFuture)),
            Divider(

              height: 1,
              color: Colors.grey
            ),
            Container(
              padding: EdgeInsets.only(bottom: 2, top: 5, left: 1, right: 1),
              child: Row(
                children: <Widget>[
                  Container(
                      height: 45,
                      margin:
                          EdgeInsets.only(top: 0, bottom: 4, right: 2, left: 2),
                      child:
                          IconButton(icon: Icon(Icons.image), onPressed: sendMedia),),
                          Container(
                      height: 45,
                      margin:
                          EdgeInsets.only(top: 0, bottom: 4, right: 2, left: 2),
                      child:
                          IconButton(icon: Icon(FlutterIcons.gif_mco), onPressed: sendGIF),),
                  Expanded(
                    child: Container(
                      height: 45,
                      padding: EdgeInsets.only(bottom: 2),
                      child: TextField(
                        controller: messageController,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 8, left: 10),
                          hintText: 'Message',
                          fillColor: Colors.grey[200],
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(width: 0, color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(width: 0, color: Colors.white),
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
        ));
  }
}

FutureBuilder chatMessages(Future<QuerySnapshot> chatMessagesFuture) {
  return FutureBuilder(
    future: chatMessagesFuture,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return circularProgress();
      }
      List<Message> messageItems = [];
      snapshot.data.documents.forEach((doc) {
        Message messageItem = Message.fromDocument(doc);
        messageItems.add(messageItem);
      });
      return ListView(
        children: messageItems,
      );
    },
  );
}
