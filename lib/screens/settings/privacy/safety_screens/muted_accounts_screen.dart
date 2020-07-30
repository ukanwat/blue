import 'package:blue/main.dart';
import 'package:blue/models/user.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/user_tile.dart';
import 'package:flutter/material.dart';
class MutedAccountsScreen extends StatefulWidget {
  static const routeName ='muted-accounts';

  @override
  _MutedAccountsScreenState createState() => _MutedAccountsScreenState();
}

class _MutedAccountsScreenState extends State<MutedAccountsScreen> {
  bool loading  = true;
  List<String> mutedAccounts; 
     List<User> mutedUsers = [];
  @override
  void initState() {

    getMutedAccounts();
 
   
    
    super.initState();
  }
     getMutedAccounts()async{
    mutedAccounts =  preferences.getStringList('muted_accounts');
     List<Future> accountFutures = [];
     List accountsDocSnapshots;
    mutedAccounts.forEach((account) {
             accountFutures.add(usersRef.document(account).get());
    });
       
accountsDocSnapshots = await Future.wait(accountFutures);

  
    setState(() {
      loading = false;
    mutedUsers = mutedUsers +
          accountsDocSnapshots.map((doc) => User.fromDocument(doc)).toList();
    });




     }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(
      context  , 'Muted Accounts'),
      body: loading? circularProgress(): ListView.builder(itemBuilder: (_,i){
         return UserTile(mutedUsers[i]);
          
      },
      
      itemCount: mutedUsers.length,
      ),
      
    );
  }
}