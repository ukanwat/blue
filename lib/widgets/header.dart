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
      title: textTitleExists
          ? title
          : Image.asset(
              'assets/icons/appbar_appicon_inverted.png',
              height: MediaQuery.of(context).viewPadding.top,
            ),
      elevation: elevation == null ? 1 : elevation,
      centerTitle: centerTitleExists ? centerTitle : true,
      automaticallyImplyLeading: implyLeadingExists ? implyLeading : true,
    ),
  );
}
