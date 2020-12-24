// Flutter imports:
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
        .containsInStringList('muted_messages', peer['peerId']);
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
  updateReportFirebase(String option) async {
    PreferencesUpdate()
        .addStringToList('reported_accounts_$option', peer['peerId']);
    var _accountDoc = await accountReportsRef.doc(peer['peerId']).get();
    if (_accountDoc.data() != null) {
      accountReportsRef
          .doc(peer['peerId'])
          .update({'$option': FieldValue.increment(1)});
    } else {
      accountReportsRef.doc(peer['peerId']).set({'$option': 1});
    }
    var _userDoc = await userReportsRef.doc(currentUser.id).get();
    if (_userDoc.data() == null) {
      userReportsRef.doc(currentUser.id).set(
        {
          '$option': [peer['peerId']]
        },
      );
    } else if (_userDoc.data()['$option'] == null) {
      userReportsRef.doc(peer['$option']).set({
        '$option': [peer['peerId']]
      }, SetOptions(merge: true));
    } else {
      userReportsRef.doc(peer['peerId']).update(
        {
          '$option': FieldValue.arrayUnion([peer['peerId']])
        },
      );
    }
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
              PreferencesUpdate()
                  .addStringToList('muted_messages', peer['peerId']);
              var _userDoc = await userReportsRef.doc(currentUser.id).get();
              print('sdfffffffffffff');
              if(_userDoc != null)
              print(_userDoc.data());
               print('sdfffffffffffff');
              if (_userDoc.data() == null) {
                userReportsRef.doc(currentUser.id).set(
                  {
                    'muted': [peer['peerId']]
                  },
                );
              } else if (_userDoc.data()['muted'] == null) {
                userReportsRef.doc(currentUser.id).set({
                  'muted': [peer['peerId']]
                }, SetOptions(merge: true));
              } else {
                userReportsRef.doc(currentUser.id).update(
                  {
                    'muted': FieldValue.arrayUnion([peer['peerId']])
                  },
                );
              }
            } else {
              PreferencesUpdate()
                  .removeStringFromList('muted_messages', peer['peerId']);
              try {
                userReportsRef.doc(currentUser.id).update(
                  {
                    'muted': FieldValue.arrayRemove([peer['peerId']])
                  },
                );
                setState(() {
                  isMuted = newValue;
                });
              } catch (e) {
                //error TODO
              }
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
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0.0,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      decoration: new BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // To make the card compact
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Text(
                              'Report',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'Tell us your reason for reporting ${peer['peerUsername']}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Divider(
                            height: 5,
                            thickness: 0.3,
                            color: Colors.grey,
                          ),
                          InkWell(
                            onTap: () async {
                              updateReportFirebase('spam');

                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 50,
                              child: Center(child: Text("It's Spam")),
                            ),
                          ),
                          Divider(
                            height: 5,
                            thickness: 0.3,
                            color: Colors.grey,
                          ),
                          InkWell(
                            onTap: () {
                              updateReportFirebase('inappropriate');
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 50,
                              child: Center(child: Text("It's Inappropriate")),
                            ),
                          ),
                          Divider(
                            height: 5,
                            thickness: 0.3,
                            color: Colors.grey,
                          ),
                          InkWell(
                            onTap: () {
                              updateReportFirebase('abusive');
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 50,
                              child: Center(child: Text("It's abusive")),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }, FluentIcons.chat_warning_24_regular),
          settingsActionTile(context, isBlocked ? 'Unblock' : 'Block', () {
            if (isBlocked) {
              setState(() {
                isBlocked = false;
              });
              PreferencesUpdate()
                  .removeStringFromList('blocked_accounts', peer['peerId']);

              try {
                userReportsRef.doc(currentUser.id).update({
                  'blocked': FieldValue.arrayRemove([peer['peerId']])
                });
                userReportsRef.doc(peer['peerId']).update({
                  'blockedBy': FieldValue.arrayRemove([currentUser.id])
                });
              } catch (e) {
// show toast or something
              }
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
                    var _userDoc =
                        await accountReportsRef.doc(currentUser.id).get();
                    var _peerDoc =
                        await accountReportsRef.doc(peer['peerId']).get();
                    if (_userDoc.data() == null) {
                      userReportsRef.doc(currentUser.id).set(
                        {
                          'blocked': [peer['peerId']]
                        },
                      );
                    } else if (_userDoc.data()['blocked'] == null) {
                      userReportsRef.doc(currentUser.id).set({
                        'blocked': [peer['peerId']]
                      }, SetOptions(merge: true));
                    } else {
                      userReportsRef.doc(currentUser.id).update(
                        {
                          'blocked': FieldValue.arrayUnion([peer['peerId']])
                        },
                      );
                    }

                    if (_peerDoc.data() == null) {
                      userReportsRef.doc(peer['peerId']).set(
                        {
                          'blockedBy': [currentUser.id]
                        },
                      );
                    } else if (_userDoc.data()['blockedBy'] == null) {
                      userReportsRef.doc(peer['peerId']).set({
                        'blockedBy': [currentUser.id]
                      }, SetOptions(merge: true));
                    } else {
                      userReportsRef.doc(peer['peerId']).update(
                        {
                          'blockedBy': FieldValue.arrayUnion([currentUser.id])
                        },
                      );
                    }
                    PreferencesUpdate()
                        .addStringToList('blocked_accounts', peer['peerId']);
                  },
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
