// Dart imports:
import 'package:universal_platform/universal_platform.dart';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue/constants/app_colors.dart';
// Package imports:
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

PreferredSize settingsHeader(BuildContext context, String title,
    {bool button, Function buttonFn, String buttonText}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(50),
    child: AppBar(
      brightness: Theme.of(context).brightness,
      titleSpacing: 0,
      backgroundColor: Theme.of(context).canvasColor,
      centerTitle: false,
      elevation: 0.4, //dd/
      actions: [
        if (button == true)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              child: Text(
                buttonText ?? 'Save',
                style: TextStyle(fontSize: 17),
              ),
              onPressed: buttonFn ?? () {},
            ),
          )
      ],
      title: Text(title,
          style:
              TextStyle(fontFamily: 'Stark Sans', fontWeight: FontWeight.w800)),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          FluentIcons.chevron_left_24_filled,
          size: 30,
        ),
        color: AppColors.blue,
        iconSize: 28,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
  );
}

Container settingsSectionTitle(
  String title,
  Icon icon,
  BuildContext context,
) {
  return Container(
    width: double.infinity,
    color: Theme.of(context).iconTheme.color == Colors.white
        ? Theme.of(context).backgroundColor
        : Color.fromRGBO(245, 245, 245, 1),
    padding: EdgeInsets.only(top: 8, bottom: 8, left: 10),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // icon,
        SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Stark Sans',
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(width: 5),
        // Icon(
        //   icon.icon,
        //   size: 18,
        //   color: AppColors.blue,
        // ),
      ],
    ),
  );
}

Container settingsSwitchListTile(
    String title, bool currentValue, Function updateValue,
    {String description}) {
  return Container(
    child: UniversalPlatform.isIOS
        ? CupertinoFormRow(
            child: CupertinoSwitch(
              value: currentValue,
              onChanged: updateValue,
              trackColor: Colors.grey,
              activeColor: AppColors.blue,
            ),
            prefix: TileText(title),
            helper: description == null ? null : TileText(description),
          )
        : SwitchListTile(
            activeColor: AppColors.blue,
            value: currentValue,
            onChanged: updateValue,
            title: Text(title),
            subtitle: description == null ? null : Text(description),
          ),
  );
}

class TileText extends StatelessWidget {
  final String text;
  TileText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Theme.of(context).iconTheme.color),
    );
  }
}

InkWell settingsPageNavigationTile(
    BuildContext context, String title, String routeName,
    {bool removeBorder}) {
  if (removeBorder == null) removeBorder = false;
  return InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: () {
      Navigator.pushNamed(context, routeName);
    },
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border(
              // bottom: BorderSide(
              //     color: Theme.of(context).iconTheme.color.withOpacity(0.16),
              //     width: removeBorder ? 0 : 1),
              )),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          Icon(FluentIcons.ios_chevron_right_20_filled)
        ],
      ),
    ),
  );
}

InkWell settingsActionTile(
    BuildContext context, String title, Function function, IconData iconData,
    {bool isRed, bool removeBorder}) {
  if (isRed == null) isRed = false;
  if (removeBorder == null) removeBorder = false;
  return InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: function,
    child: Container(
      alignment: Alignment.centerLeft,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: isRed
                ? TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.red)
                : TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          isRed
              ? Icon(
                  iconData,
                  color: Colors.red,
                )
              : Icon(
                  iconData,
                  color: Theme.of(context).iconTheme.color.withOpacity(0.9),
                )
        ],
      ),
      decoration: BoxDecoration(
          border: Border(
              // bottom: BorderSide(
              //     color: Theme.of(context).iconTheme.color.withOpacity(0.16),
              //     width: removeBorder ? 0 : 1),
              )),
    ),
  );
}
