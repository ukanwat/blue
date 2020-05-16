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
      ));
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
        
        ],
      ));
}

SwitchListTile settingsSwitchListTile(
    String title, String description, bool currentValue, Function updateValue) {
  return SwitchListTile(
    value: currentValue,
    onChanged: updateValue,
    title: Text(title),
    subtitle: Text(description),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          Icon(
            Icons.keyboard_arrow_right,
          ),
        ],
      ),
    ),
  );
}
