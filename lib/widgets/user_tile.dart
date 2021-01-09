// Flutter imports:
import 'package:blue/main.dart';
import 'package:blue/services/functions.dart';
import 'package:blue/services/go_to.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:blue/models/user.dart';
import 'package:blue/screens/profile_screen.dart';
enum Tile{
  block,mute
}
class UserTile extends StatefulWidget {
  final User user;
  final Tile type;
  UserTile(this.user,this.type);

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {

  bool undo = false;
  String groupChatId;
  Map peer = {};
  @override
  void initState() {
    print(widget.user.toString());
     if (currentUser.id.hashCode <= widget.user.id.hashCode) {
      groupChatId = '${currentUser.id}-${widget.user.id}';
    } else {
      groupChatId = '${widget.user.id}-${currentUser.id}';
    }
      peer = {
                  'peerId': widget.user.id,
                  'peerUsername': widget.user.username,
                  'groupChatId': groupChatId,
                  'peerImageUrl': widget.user.photoUrl,
                  'peerName': widget.user.name,
                };
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
   
    return  ListTile(onTap: () {
      setState(() {
        undo = !undo;
      });
    if(widget.type == Tile.block){
      if(undo){
         Functions().unblockUser(peer);
      }else{
 Functions().blockUser(peer);
      }
    }else if(widget.type == Tile.mute){
        if(undo){
        Functions().unmuteUser(peer);
      }else{
         Functions().muteUser(peer);
      }
    }
    },
              leading: Container(
                child: GestureDetector(
onTap: (){
  GoTo().profileScreen(context, widget.user.id);
},
                                child: Container(
                                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(widget.user.photoUrl),
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
              trailing: Text('${undo?'':'Un'}${widget.type.toString().substring(5)}',style: TextStyle(color: Colors.blue,fontSize: 20),),
            )
         
    ;
  }
}

