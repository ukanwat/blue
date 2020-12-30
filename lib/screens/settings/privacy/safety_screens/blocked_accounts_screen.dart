// Flutter imports:
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
  List<User> blockedUsers = [];
  @override
  void initState() {
    getBlockedAccounts();
    super.initState();
  }

  getBlockedAccounts() async {
    DocumentSnapshot _doc;
    try {
      _doc = await userReportsRef
          .doc(currentUser.id)
          .get(GetOptions(source: Source.cache));
    } catch (e) {}
    if (_doc == null) {
      _doc = await userReportsRef.doc(currentUser.id).get();
    } 
    else if (!_doc.exists) {
      _doc = await userReportsRef.doc(currentUser.id).get();
    }
    if(_doc == null){
      setState(() {
        loading = false;
      });
      return;
    }else if(_doc.data()['blocked'] == null){
  setState(() {
        loading = false;
      });
      return;
    }
    blockedAccounts = _doc.data()['blocked'];
    List<Future> accountFutures = [];
    List accountsDocSnapshots;
    blockedAccounts.forEach((account) {
       if(account != null)
      accountFutures.add(usersRef.doc(account).get());
    });
    accountsDocSnapshots = await Future.wait(accountFutures);
    setState(() {
      loading = false;
      blockedUsers = blockedUsers +
          accountsDocSnapshots.map((doc) => User.fromDocument(doc.data())).toList();
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
                return UserTile(blockedUsers[i],Tile.block);
              },
              itemCount: blockedUsers.length,
            ),
    );
  }
}
