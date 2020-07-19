import 'package:blue/main.dart';
import 'package:blue/models/user.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/user_tile.dart';
import 'package:flutter/material.dart';
class BlockedAccountsScreen extends StatefulWidget {
  static const routeName ='blocked-accounts';

  @override
  _BlockedAccountsScreenState createState() => _BlockedAccountsScreenState();
}

class _BlockedAccountsScreenState extends State<BlockedAccountsScreen> {
  bool loading  = true;
  List<String> blockedAccounts; 
     List<User> blockedUsers = [];
  @override
  void initState() {

    getBlockedAccounts();
 
   
    
    super.initState();
  }
     getBlockedAccounts()async{
    blockedAccounts =  preferences.getStringList('blocked_accounts');
     List<Future> accountFutures = [];
     List accountsDocSnapshots;
    blockedAccounts.forEach((account) {
             accountFutures.add(usersRef.document(account).get());
    });
       
accountsDocSnapshots = await Future.wait(accountFutures);

  
    setState(() {
      loading = false;
    blockedUsers = blockedUsers +
          accountsDocSnapshots.map((doc) => User.fromDocument(doc)).toList();
    });




     }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(
      context  , 'Blocked Accounts'),
      body: loading? circularProgress(): ListView.builder(itemBuilder: (_,i){
         return UserTile(blockedUsers[i]);
          
      },
      
      itemCount: blockedUsers.length,
      ),
      
    );
  }
}