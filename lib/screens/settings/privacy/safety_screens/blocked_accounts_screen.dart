// Flutter imports:
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/models/user.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/user_tile.dart';

class BlockedAccountsScreen extends StatefulWidget {
  static const routeName = 'blocked-accounts';

  @override
  _BlockedAccountsScreenState createState() => _BlockedAccountsScreenState();
}

class _BlockedAccountsScreenState extends State<BlockedAccountsScreen> {
  bool loading = true;
  List blockedAccounts;
  List<dynamic> blockedUsers = [];
  @override
  void initState() {
    getBlockedAccounts();
    super.initState();
  }

  getBlockedAccounts() async {
    dynamic accounts = await Hasura.blockedUsers();
    setState(() {
      loading = false;
      blockedUsers = blockedUsers +
          accounts
              .map((doc) => User.fromDocument(doc['blocked_user']))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Blocked Accounts'),
      body: loading
          ? circularProgress()
          : ListView.builder(
              itemBuilder: (_, i) {
                return UserTile(blockedUsers[i], Tile.block);
              },
              itemCount: blockedUsers.length,
            ),
    );
  }
}
