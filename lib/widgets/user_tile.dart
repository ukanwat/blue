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
    print(widget.user.toString());

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
        setState(() {
          undo = !undo;
        });
        if (widget.type == Tile.block) {
          if (undo) {
            Functions().unblockUser(peer);
          } else {
            Functions().blockUser(peer);
          }
        } else if (widget.type == Tile.mute) {
          if (undo) {
            Functions().unmuteUser(peer);
          } else {
            Functions().muteUser(peer);
          }
        } else if (widget.type == Tile.follow) {
          GoTo().profileScreen(context, widget.user.userId);
        }
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
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        widget.user.username,
        style: TextStyle(),
      ),
      trailing: (widget.type == Tile.follow)
          ? follow
              ? Container(
                  width: 10,
                )
              : TextButton(
                  child: Text(
                    'Follow',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    Functions().handleFollowUser(widget.user.userId);
                    setState(() {
                      follow = true;
                    });
                  },
                )
          : Text(
              '${undo ? '' : 'Un'}${widget.type.toString().substring(5)}',
              style: TextStyle(color: Colors.blue, fontSize: 20),
            ),
    );
  }
}
