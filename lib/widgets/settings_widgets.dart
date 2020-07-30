import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

PreferredSize settingsHeader(BuildContext context, String title) {
  return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
centerTitle: true,
        elevation: 1,
        title: Text(title,style: TextStyle(
color: Theme.of(context).iconTheme.color

        )),
        automaticallyImplyLeading: false,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.blue,
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
        
        ],        ),);
}

SwitchListTile settingsSwitchListTile(

    String title,bool currentValue, Function updateValue, {String description} ) {
  return SwitchListTile(
    activeColor: Colors.blue,
    value: currentValue,
    onChanged: updateValue,
    title: Text(title),
    subtitle: description == null ? null:Text(description),
  );
}

InkWell settingsPageNavigationTile(
    BuildContext context, String title, String routeName) {
  return InkWell(
    onTap: () {
      Navigator.pushNamed(context, routeName);
    },
    child: Container(width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
    ),
  );
}
 
InkWell settingsActionTile(
    BuildContext context, String title, Function function) {
  return InkWell(
    onTap: function,
    child: Container(alignment: Alignment.centerLeft,width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: 
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
    ),
  );
} 
