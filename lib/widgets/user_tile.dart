// Flutter imports:
import 'package:blue/constants/strings.dart';
import 'package:blue/main.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/functions.dart';
import 'package:blue/services/go_to.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:blue/models/user.dart';
import 'package:blue/screens/profile_screen.dart';

enum Tile { block, mute, follow }

class UserTile extends StatefulWidget {
  final User user;
  final Tile type;
  UserTile(this.user, this.type);

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  bool undo = false;
  String groupChatId;
  Map peer = {};
  bool follow = false;
  @override
  void initState() {
    peer = {
      'peerId': widget.user.userId,
      'peerUsername': widget.user.username,
      'peerImageUrl': widget.user.avatarUrl,
      'peerName': widget.user.name,
    };

    if (widget.type == Tile.follow) {
      follow = Boxes.followingBox.containsKey(widget.user.userId);
    }
    if (widget.user.userId == currentUser.userId) {
      follow = true;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () {
          GoTo().profileScreen(context, widget.user.userId);
        },
        leading: Container(
          child: GestureDetector(
            onTap: () {
              GoTo().profileScreen(context, widget.user.userId);
            },
            child: Container(
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                    widget.user.avatarUrl ?? Strings.emptyAvatarUrl),
              ),
            ),
          ),
        ),
        title: Text(
          widget.user.name,
          style: TextStyle(
              fontFamily: 'Stark Sans',
              fontWeight: FontWeight.w600,
              fontSize: 18),
        ),
        subtitle: Text(
          widget.user.username,
          style: TextStyle(fontSize: 13),
        ),
        trailing: GestureDetector(
          child: follow
              ? Container(
                  width: 10,
                )
              : Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 3.5,
                        color: (widget.type == Tile.follow)
                            ? Colors.blue
                            : undo
                                ? Colors.blue
                                : Colors.red,
                      )),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                    child: Text(
                      (widget.type == Tile.follow)
                          ? 'Follow'
                          : '${undo ? '' : 'Un'}${widget.type.toString().substring(5)}',
                      style: TextStyle(
                          color: (widget.type == Tile.follow)
                              ? Colors.blue
                              : undo
                                  ? Colors.blue
                                  : Colors.red,
                          fontFamily: 'Stark Sans',
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
          onTap: () {
            if (widget.type == Tile.block) {
              setState(() {
                undo = !undo;
              });
              if (undo) {
                Functions().unblockUser(peer);
              } else {
                Functions().blockUser(peer);
              }
            } else if (widget.type == Tile.mute) {
              setState(() {
                undo = !undo;
              });
              if (undo) {
                Functions().unmuteUser(peer);
              } else {
                Functions().muteUser(peer);
              }
            } else if (widget.type == Tile.follow) {
              if (follow) {
                return;
              }
              Functions().handleFollowUser(widget.user.userId);
              setState(() {
                follow = true;
              });
            }
          },
        ));
  }
}
