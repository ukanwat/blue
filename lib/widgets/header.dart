// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

PreferredSize header(context,
    {Widget actionButton,
    Widget actionButton2,
    Widget leadingButton,
    Widget title,
    bool centerTitle,
    double elevation,
    bool implyLeading}) {
  bool textTitleExists = title != null;
  bool centerTitleExists = centerTitle != null;
  bool actionButtonExists = actionButton != null;
  bool actionButton2Exists = actionButton2 != null;
  bool implyLeadingExists = implyLeading != null;
  return PreferredSize(
    preferredSize: Size.fromHeight(50.0),
    child: AppBar(
      bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: Theme.of(context).iconTheme.color.withOpacity(0.1),
          )),
      brightness: Theme.of(context).brightness,
      systemOverlayStyle:
          SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      leading: leadingButton,
      actions: actionButtonExists
          ? (actionButton2Exists
              ? <Widget>[actionButton2, actionButton]
              : <Widget>[actionButton])
          : null,
      backgroundColor: Theme.of(context).backgroundColor,
      title: textTitleExists ? title : Text(''),
      elevation: elevation == null ? 1 : elevation,
      centerTitle: centerTitleExists ? centerTitle : true,
      automaticallyImplyLeading: implyLeadingExists ? implyLeading : true,
    ),
  );
}
