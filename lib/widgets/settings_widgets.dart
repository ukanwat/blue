// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

PreferredSize settingsHeader(BuildContext context, String title){
  return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: AppBar(titleSpacing: 0,
        backgroundColor: Theme.of(context).canvasColor,
centerTitle: false,
        elevation: 0.4,
        title: Text(title,style: TextStyle(
fontFamily: 'Techna Sans Regular'
        )),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon:Icon( FluentIcons.chevron_left_24_filled,size: 30,),
          color: Colors.blue,iconSize: 28,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),);
}

Container settingsSectionTitle(String title, Icon icon,BuildContext context, ) {
  return Container(
    width: double.infinity,
    color: Theme.of(context).iconTheme.color == Colors.white?Theme.of(context).backgroundColor:Theme.of(context).canvasColor,
      padding: EdgeInsets.only(top: 24, bottom: 10, left: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          
          icon,  SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Theme.of(context).iconTheme.color.withOpacity(0.7)),
          ),
        
        ],        ),);
}

Container settingsSwitchListTile(

    String title,bool currentValue, Function updateValue, {String description} ) {
  return Container(
    child: SwitchListTile(
      activeColor: Colors.blue,
      value: currentValue,
      onChanged: updateValue,
      title: Text(title),
      subtitle: description == null ? null:Text(description),
    ),
  );
}

InkWell settingsPageNavigationTile(
    BuildContext context, String title, String routeName,{bool removeBorder}) {
         if(removeBorder == null)
     removeBorder = false;
  return InkWell(
    onTap: () {
      Navigator.pushNamed(context, routeName);
    },
    child: Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width:removeBorder? 0:1),)),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child:  
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),Icon(FluentIcons.ios_chevron_right_20_filled)
            ],
          ),
      
    ),
  );
}
 
InkWell settingsActionTile(
    BuildContext context, String title, Function function,IconData iconData,{bool isRed,bool removeBorder} ) {
      if(isRed == null)
      isRed = false;
       if(removeBorder == null)
     removeBorder = false;
  return InkWell(
    onTap: function,
    child: Container(alignment: Alignment.centerLeft,width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: 
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: isRed? TextStyle(fontSize: 16, fontWeight: FontWeight.w400,color: Colors.red):TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),isRed?Icon(iconData,color: Colors.red,):Icon(iconData,color: Theme.of(context).iconTheme.color.withOpacity(0.9),)
            ],
          ),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width:removeBorder? 0:1),)),
    ),
  );
} 
