import 'package:blue/models/user.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/user_tile.dart';
import 'package:flutter/material.dart';

class PaginatedUserTiles extends StatefulWidget {
  final Tile type;
  PaginatedUserTiles(this.type);
  @override
  _PaginatedUserTilesState createState() => _PaginatedUserTilesState();
}

class _PaginatedUserTilesState extends State<PaginatedUserTiles> {
  dynamic _userTiles = [];
  bool loaded = false;
  int lastDoc;
  bool empty = false;
  int length = 15;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    addUserTiles();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          empty != true &&
          loaded != true) {
        setState(() {
          addUserTiles();
        });
      }
    });
    super.initState();
  }

  addUserTiles() async {
    if (lastDoc == null) {
      dynamic _u;
      _u = await Hasura.getChatUsers();
      _userTiles = _u.map((doc) => UserTile(User(), widget.type)).toList();
      if (this.mounted) setState(() {});
      if (_u.length == 0) {
        setState(() {
          empty = true;
        });
        return;
      }
      lastDoc = _u.length;
      if (_u.length < length) {
        setState(() {
          loaded = true;
        });
        return;
      }
    } else {
      var _snapshot;
      _snapshot = await Hasura.getChatUsers();
      _userTiles.addAll(
          _snapshot.map((doc) => UserTile(User(), widget.type)).toList());

      if (_snapshot.length < length) {
        setState(() {
          loaded = true;
        });
        return;
      }
      lastDoc = lastDoc + _snapshot.length;
    }

    //  List d = [];
    //  d.elementAt(i)
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemCount: _userTiles.length + 1,
      itemBuilder: (context, i) {
        if (i == _userTiles.length)
          return Container(
            height: 100,
            child: loaded ? Center() : circularProgress(),
          );
        return _userTiles.elementAt(i);
      },
    );
  }
}
