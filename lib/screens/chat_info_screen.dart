// Flutter imports:
import 'package:blue/services/functions.dart';
import 'package:blue/widgets/user_report_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/show_dialog.dart';

class ChatInfoScreen extends StatefulWidget {
  static const routeName = 'chat-info';
  @override
  _ChatInfoScreenState createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  Map<String, String> peer;
  bool isMuted;
  bool isBlocked;

  @override
  void didChangeDependencies() {
    print(preferences.getStringList('blocked_accounts'));
    peer = ModalRoute.of(context).settings.arguments as Map;
    isMuted = PreferencesUpdate()
        .containsInStringList('muted_messages', peer['peerId']);

    isBlocked = PreferencesUpdate()
        .containsInStringList('blocked_accounts', peer['peerId']);
    super.didChangeDependencies();
  }
   deleteMessagesData(String peerId, DateTime peerDeleteTime)async{
    var messagesToDelete =   await   messagesRef.doc(peer['groupChatId']).collection(peer['groupChatId']).where('timestamp',isLessThan: peerDeleteTime).get();
    int times = (messagesToDelete.docs.length/400).ceil();
    for(int i = 1; i < times ; i++){
       WriteBatch _batch = FirebaseFirestore.instance.batch();
         messagesToDelete.docs.sublist(400*(i-1),400*(i)).forEach((doc) { 
       _batch.delete(doc.reference);
     });
        await _batch.commit();
    }
      WriteBatch _batch = FirebaseFirestore.instance.batch();
         messagesToDelete.docs.sublist(400*times).forEach((doc) { 
       _batch.delete(doc.reference);
     });
        await _batch.commit();
//TODO devise a more foolproof way of deleting docs
    //TODO delete images too from storage
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: header(
        context,
        elevation: 0.5,
        title: Text(
          'Info',
          style: TextStyle(),
        ),
        centerTitle: false,
        leadingButton: CupertinoNavigationBarBackButton(),
      ),
      body: Column(
        children: <Widget>[
          Container(
              height: 120,
              margin: EdgeInsets.only(top: 40, bottom: 5),
              width: double.infinity,
              child: Center(
                child: CircleAvatar(
                  radius: 60.0,
                  backgroundColor: Theme.of(context).backgroundColor,
                  backgroundImage: CachedNetworkImageProvider(
                    (peer['peerImageUrl']),
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            child: Text(
              peer['peerName'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
             Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border(
                  bottom: BorderSide(
                      color:
                          Theme.of(context).iconTheme.color.withOpacity(0.16),
                      width: 1),
                )),
              ),
          settingsSwitchListTile('Mute Messages', isMuted, (newValue) async {
            if (newValue == true) {
              setState(() {
                isMuted = newValue;
              });
             Functions().muteUser(peer);
            } else {
                setState(() {
                  isMuted = newValue;
                });
                Functions().unmuteUser(peer);
            }
          }),  
           Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border(
                  bottom: BorderSide(
                      color:
                          Theme.of(context).iconTheme.color.withOpacity(0.16),
                      width: 1),
                )),
              ),
          settingsActionTile(context, 'Report', () {
          showDialog(context: context,builder: (context) {
            return UserReportDialog(peer: peer,);
          },);
          }, FluentIcons.chat_warning_24_regular),
          settingsActionTile(context, isBlocked ? 'Unblock' : 'Block', () {
            if (isBlocked) {
              setState(() {
                isBlocked = false; 
              });
            Functions().unblockUser(peer);
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) => ShowDialog(
                  title: 'Block',
                  description:
                      'You will no longer receive messages and notifications from ${peer['peerUsername']}?',
                  leftButtonText: 'Cancel',
                  rightButtonText: 'Block',
                  rightButtonFunction: () async {
                    Navigator.pop(context);
                    setState(() {
                      isBlocked = true;
                    });
                     Functions().blockUser(peer);
                  }
                ),
              );
            }
          }, FluentIcons.block_24_regular),
          settingsActionTile(context, 'Delete Messages', () {
            showDialog(
                context: context,
                builder: (BuildContext context) => ShowDialog(
                    title: 'Delete Messages',
                    description: 'This will permanently delete your messages',
                    leftButtonText: 'Cancel',
                    rightButtonText: 'Delete',
                    rightButtonFunction: () async {
                      Navigator.pop(context);
                      var _userDoc =
                        await accountReportsRef.doc(currentUser.id).get();  // TODO dont need to get this doc (also in other cases)
                      DateTime  nowTime =       DateTime.now();
                       if (_userDoc.data() == null) {
                      userReportsRef.doc(currentUser.id).set(
                        {
                          'deleteMessages': {peer['peerId']: nowTime}
                        },
                      );
                    } else {
                      userReportsRef.doc(currentUser.id).set({
                        'deleteMessages': {peer['peerId']: nowTime}
                      }, SetOptions(merge: true));
                    } 
                       var _peerDoc =
                        await accountReportsRef.doc(currentUser.id).get(); 
                     if(_peerDoc.data()['deleteMessages'][peer['peerId']] != null){
                       DateTime peerDeleteTime = _peerDoc.data()['deleteMessages'][peer['peerId']];
                       deleteMessagesData(peer['peerId'],peerDeleteTime,);
                     }
                      
                    }));
          }, FluentIcons.delete_24_regular,isRed: true),
        ],
      ),
    );
  }
}
