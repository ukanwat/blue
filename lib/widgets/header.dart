import 'package:flutter/material.dart';

PreferredSize header(context,
    {Widget actionButton,
    Widget leadingButton,
    Widget title,
    bool centerTitle}) {
  bool textTitleExists = title != null;
  bool centerTitleExists = centerTitle != null;
  bool actionButtonExists = actionButton != null;
  return PreferredSize(
    preferredSize: Size.fromHeight(50.0),
    child: AppBar(
      leading: leadingButton,
      actions: actionButtonExists ? <Widget>[actionButton] : null,
      backgroundColor: Colors.white,
      title: textTitleExists
          ? title
          : Image.asset(
              'assets/icons/appbar_appicon_inverted.png',
              height: MediaQuery.of(context).viewPadding.top,
            ),
      elevation: 0,
      centerTitle: centerTitleExists ? centerTitle : true,
    ),
  );
}
