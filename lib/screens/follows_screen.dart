// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/models/user.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/user_tile.dart';

class FollowsScreen extends StatefulWidget {
  static const String routeName = 'follows';
  @override
  _FollowsScreenState createState() => _FollowsScreenState();
}

class _FollowsScreenState extends State<FollowsScreen> {
  bool loading = true;
  List accounts;
  List<dynamic> users = [];
  bool following;
  int profileId;
  @override
  void didChangeDependencies() {
    Map m = ModalRoute.of(context).settings.arguments as Map;
    following = m['f'];
    profileId = m['i'];
    getFollowsAccounts();
    super.didChangeDependencies();
  }

  getFollowsAccounts() async {
    dynamic accounts = await Hasura.getFollowsUsers(following, profileId);
    setState(() {
      loading = false;
      users = users +
          accounts
              .map((doc) =>
                  User.fromDocument(doc[!following ? 'follower' : 'following']))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, following ? 'Following' : 'Followers'),
      body: loading
          ? circularProgress()
          : ListView.builder(
              itemBuilder: (_, i) {
                return UserTile(users[i], Tile.follow);
              },
              itemCount: users.length,
            ),
    );
  }
}
