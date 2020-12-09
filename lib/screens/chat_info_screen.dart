import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/show_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatInfoScreen extends StatefulWidget {
  static const routeName = 'chat-info';
  @override
  _ChatInfoScreenState createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  List<String> muteMessages = preferences.containsKey('muted_messages')
      ? preferences.getStringList('muted_messages')
      : []; //TODO might hit the doc limit
  Map<String, String> peer;
  bool isMuted;
  List<String> blockedAccounts = preferences.containsKey('blocked_accounts')
      ? preferences.getStringList('blocked_accounts')
      : [];
  bool isBlocked;
  List<String> reportedAccountsSpam =
      preferences.containsKey('reported_accounts_spam')
          ? preferences.getStringList('reported_accounts_spam')
          : [];
  bool isReportedSpam;
  List<String> reportedAccountsInappropriate =
      preferences.containsKey('reported_accounts_inappropriate')
          ? preferences.getStringList('reported_accounts_inappropriate')
          : [];
  bool isReportedInappropriate;
  List<String> reportedAccountsAbusive =
      preferences.containsKey('reported_accounts_abusive')
          ? preferences.getStringList('reported_accounts_abusive')
          : [];
  @override
  void didChangeDependencies() {
    print(preferences.getStringList('blocked_accounts'));
    peer = ModalRoute.of(context).settings.arguments as Map;
    isMuted = muteMessages.contains(peer['peerId']);

    isBlocked = blockedAccounts.contains(peer['peerId']);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: header(
        context,
        title: Text(
          'Info',
          style: TextStyle(),
        ),
        centerTitle: false,
        leadingButton: CupertinoNavigationBarBackButton(),
      ),
      body: Column(
        children: <Widget>[
          settingsSwitchListTile('Mute Messages', isMuted, (newValue) {
            setState(() {
              isMuted = newValue;
            });
            if (newValue == true) {
              List<String> mutedMessages =
                  preferences.containsKey('muted_messages')
                      ? preferences.getStringList('muted_messages')
                      : [];
              mutedMessages.add(peer['peerId']);
              preferences.setStringList('muted_messages', mutedMessages);
              preferencesRef.doc(currentUser.id).update({
                'muted_messages': FieldValue.arrayUnion([peer['peerId']])
              });
            } else {
              List<String> mutedMessages =
                  preferences.containsKey('muted_messages')
                      ? preferences.getStringList('muted_messages')
                      : [];
              mutedMessages.remove(peer['peerId']);
              preferences.setStringList('muted_messages', mutedMessages);
              preferencesRef.doc(currentUser.id).update({
                'muted_messages': FieldValue.arrayRemove([peer['peerId']])
              });
            }
          }),
          settingsActionTile(
            context,
            'Report',
            () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => Dialog(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
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
                                onTap: () {
                                  if (!reportedAccountsSpam
                                      .contains(peer['peerId'])) {
                                    reportedAccountsSpam.add(peer['peerId']);
                                    preferences.setStringList(
                                        'reported_accounts_spam',
                                        reportedAccountsSpam);
                                    accountReportsRef
                                        .doc(peer['peerId'])
                                        .update(
                                            {'spam': FieldValue.increment(1)});
                                    preferencesRef
                                        .doc(currentUser.id)
                                        .update({
                                      'reported_accounts_spam':
                                          FieldValue.arrayUnion(
                                              [peer['peerId']])
                                    });
                                  }
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
                                  if (!reportedAccountsInappropriate
                                      .contains(peer['peerId'])) {
                                    reportedAccountsInappropriate
                                        .add(peer['peerId']);
                                    preferences.setStringList(
                                        'reported_accounts_inappropriate',
                                        reportedAccountsInappropriate);
                                    accountReportsRef
                                        .doc(peer['peerId'])
                                        .update({
                                      'inappropriate': FieldValue.increment(1)
                                    });
                                    preferencesRef
                                        .doc(currentUser.id)
                                        .update({
                                      'reported_accounts_inappropriate':
                                          FieldValue.arrayUnion(
                                              [peer['peerId']])
                                    });
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  height: 50,
                                  child:
                                      Center(child: Text("It's Inappropriate")),
                                ),
                              ),
                              Divider(
                                height: 5,
                                thickness: 0.3,
                                color: Colors.grey,
                              ),
                              InkWell(
                                onTap: () {
                                  if (!reportedAccountsAbusive
                                      .contains(peer['peerId'])) {
                                    reportedAccountsAbusive.add(peer['peerId']);
                                    preferences.setStringList(
                                        'reported_accounts_abusive',
                                        reportedAccountsAbusive);
                                    accountReportsRef
                                        .doc(peer['peerId'])
                                        .update({
                                      // TODO create report document upn new user creation otherwise document update will fail
                                      'abusive': FieldValue.increment(1)
                                    });
                                    preferencesRef
                                        .doc(currentUser.id)
                                        .update({
                                      'reported_accounts_abusive':
                                          FieldValue.arrayUnion(
                                              [peer['peerId']])
                                    });
                                  }
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
                      ));
            },
          ),
          settingsActionTile(context, isBlocked ? 'Unblock' : 'Block', () {
            if (isBlocked) {
              preferencesRef.doc(currentUser.id).update({
                'blocked_accounts': FieldValue.arrayRemove([peer['peerId']])
              });
              blockedAccounts.remove(peer['peerId']);
              preferences.setStringList('blocked_accounts', blockedAccounts);
              setState(() {
                isBlocked = false;
              });
              print(isBlocked);
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => ShowDialog(
                      title: 'Block',
                      description:
                          'You will no longer receive messages and notifications from ${peer['peerUsername']}?',
                      leftButtonText: 'Cancel',
                      rightButtonText: 'Block',
                      rightButtonFunction: () {
                        Navigator.pop(context);
                        preferencesRef.doc(currentUser.id).update({
                          'blocked_accounts':
                              FieldValue.arrayUnion([peer['peerId']])
                        });
                        print(blockedAccounts);
                        blockedAccounts.add(peer['peerId']);
                        print(blockedAccounts);
                        preferences.setStringList(
                            'blocked_accounts', blockedAccounts);
                        setState(() {
                          isBlocked = true;
                        });

                        print(isBlocked);
                      }));
            }
          }),
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
                      var lastDocument = await messagesRef
                          .doc(peer['groupChatId'])
                          .collection(peer['groupChatId'])
                          .orderBy('timestamp', descending: true)
                          .limit(1)
                          .get();
                      var lastDocumentId = lastDocument.docs.first
                          .id; // can also get last doc locally
                      List lastDeletedBy =
                          lastDocument.docs.first.data()['lastDeletedBy'];
                      if (lastDeletedBy == [currentUser.id])
                        lastDeletedBy = null;
                      if (lastDeletedBy == null)
                        lastDeletedBy = [currentUser.id];
                      if (lastDeletedBy == [peer['peerId']])
                        lastDeletedBy = [currentUser.id, peer['peerId']];

                      if (lastDeletedBy != null) {
                        messagesRef
                            .doc(peer['groupChatId'])
                            .collection(peer['groupChatId'])
                            .doc(lastDocumentId)
                            .set({
                          'lastDeletedBy': lastDeletedBy //TODO :to test
                        }, SetOptions(merge: true));
                      }
                    }));
          }),
        ],
      ),
    );
  }
}
