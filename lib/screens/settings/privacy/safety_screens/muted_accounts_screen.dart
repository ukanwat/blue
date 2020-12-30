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

class MutedAccountsScreen extends StatefulWidget {
  static const routeName ='muted-accounts';

  @override
  _MutedAccountsScreenState createState() => _MutedAccountsScreenState();
}

class _MutedAccountsScreenState extends State<MutedAccountsScreen> {
  bool loading  = true;
  List mutedAccounts; 
     List<User> mutedUsers = [];
  @override
  void initState() {

    getMutedAccounts();
 
   
    
    super.initState();
  }
     getMutedAccounts()async{
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
    }else if(_doc.data()['muted'] == null){
  setState(() {
        loading = false;
      });
      return;
    }
    mutedAccounts = _doc.data()['muted'];
    List<Future> accountFutures = [];
    List accountsDocSnapshots;
    mutedAccounts.forEach((account) {
      if(account != null)
      accountFutures.add(usersRef.doc(account).get());
    });
accountsDocSnapshots = await Future.wait(accountFutures);

  
    setState(() {
      loading = false;
    mutedUsers = mutedUsers +
          accountsDocSnapshots.map((doc) => User.fromDocument(doc.data())).toList();
    });
    



     }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(
      context  , 'Muted Accounts'),
      body: loading? circularProgress(): ListView.builder(itemBuilder: (_,i){
         return UserTile(mutedUsers[i],Tile.mute);
          
      },
      
      itemCount: mutedUsers.length,
      ),
      
    );
  }
}
