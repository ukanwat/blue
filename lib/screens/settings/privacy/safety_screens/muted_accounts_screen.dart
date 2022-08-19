// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/models/user.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/user_tile.dart';

class MutedAccountsScreen extends StatefulWidget {
  static const routeName = 'muted-accounts';

  @override
  _MutedAccountsScreenState createState() => _MutedAccountsScreenState();
}

class _MutedAccountsScreenState extends State<MutedAccountsScreen> {
  bool loading = true;
  List mutedAccounts;
  List<dynamic> mutedUsers = [];
  @override
  void initState() {
    getMutedAccounts();

    super.initState();
  }

  getMutedAccounts() async {
    dynamic accounts = await Hasura.mutedUsers();
    setState(() {
      loading = false;
      mutedUsers =
          accounts.map((doc) => User.fromDocument(doc['muted_user'])).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Muted Accounts'),
      body: loading
          ? circularProgress()
          : ListView.builder(
              itemBuilder: (_, i) {
                return UserTile(mutedUsers[i], Tile.mute);
              },
              itemCount: mutedUsers.length,
            ),
    );
  }
}
