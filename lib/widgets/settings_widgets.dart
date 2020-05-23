import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

PreferredSize settingsHeader(BuildContext context, String title) {
  return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,
        title: Text(title,style: TextStyle(color: Theme.of(context).primaryColor),),
        automaticallyImplyLeading: false,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.grey,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),);
}

Container settingsSectionTitle({String title, Icon icon}) {
  return Container(
      padding: EdgeInsets.only(top: 15, bottom: 12, left: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          
          icon,  SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        
        ],        ));
}

SwitchListTile settingsSwitchListTile(
    String title,bool currentValue, Function updateValue, {String description} ) {
  return SwitchListTile(
    value: currentValue,
    onChanged: updateValue,
    title: Text(title),
    subtitle: description == null ? null:Text(description),
  );
}

GestureDetector settingsPageNavigationTile(
    BuildContext context, String title, String routeName) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, routeName);
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
    ),
  );
}
 
GestureDetector settingsActionTile(
    BuildContext context, String title, Function function) {
  return GestureDetector(
    onTap: function,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: 
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
    ),
  );
} 
