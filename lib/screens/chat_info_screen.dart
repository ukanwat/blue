// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/services/functions.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/show_dialog.dart';
import 'package:blue/widgets/user_report_dialog.dart';
import '../widgets/progress.dart';

class ChatInfoScreen extends StatefulWidget {
  static const routeName = 'chat-info';
  @override
  _ChatInfoScreenState createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  Map peer;
  bool isMuted;
  bool isBlocked;
  bool infoLoaded = false;
  @override
  void didChangeDependencies() {
    peer = ModalRoute.of(context).settings.arguments;

    isMuted =
        PreferencesUpdate().containsInList('muted_messages', peer['peerId']);

    isBlocked =
        PreferencesUpdate().containsInList('blocked_accounts', peer['peerId']);
    checkValues();
    super.didChangeDependencies();
  }

  checkValues() async {
    var data = await Hasura.checkUserAllInfo(peer['peerId']);
    setState(() {
      isMuted = data['muted'];
      isBlocked = data['blocked'];
    });
    infoLoaded = true;
  }

  deleteMessagesData(String peerId, DateTime peerDeleteTime) async {}

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
      body: !infoLoaded
          ? circularProgress()
          : Column(
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
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
                settingsSwitchListTile('Mute Messages', isMuted,
                    (newValue) async {
                  if (!infoLoaded) {
                    return;
                  }
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
                  showDialog(
                    context: context,
                    builder: (context) {
                      return UserReportDialog(
                        peer: peer,
                      );
                    },
                  );
                }, FluentIcons.chat_warning_24_regular),
                settingsActionTile(context, isBlocked ? 'Unblock' : 'Block',
                    () {
                  if (!infoLoaded) {
                    return;
                  }
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
                          }),
                    );
                  }
                }, FluentIcons.block_24_regular),
                settingsActionTile(context, 'Delete Messages', () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => ShowDialog(
                          title: 'Delete Messages',
                          description:
                              'This will permanently delete your messages',
                          leftButtonText: 'Cancel',
                          rightButtonText: 'Delete',
                          rightButtonFunction: () async {
                            Navigator.pop(context);
                          }));
                }, FluentIcons.delete_24_regular, isRed: true),
              ],
            ),
    );
  }
}
