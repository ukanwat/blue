// Flutter imports:
import 'package:blue/services/preferences_update.dart';
import 'package:flutter/foundation.dart';
import 'package:blue/services/boxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Package imports:

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  bool _darkTheme;

  bool get darkTheme => _darkTheme;
  
  ThemeNotifier(BuildContext context) {
    _darkTheme = true;
    _loadFromPrefs(context);
  }

  toggleTheme(var value ,BuildContext context) {
    _darkTheme = value;
     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
       statusBarIconBrightness: Brightness.light,
       statusBarBrightness: Brightness.light,
       statusBarColor:value == null? Colors.grey:value? Color.fromRGBO(20, 20, 20, 1): Color.fromRGBO(170, 170, 170, 1),
      systemNavigationBarDividerColor: Colors.grey[900],
      systemNavigationBarIconBrightness: Brightness.light
      ));
    _saveToPrefs();
    notifyListeners();
  }



  _loadFromPrefs(BuildContext context) async {
    if(Boxes.preferenceBox == null){
         _darkTheme = false;
    }else{
_darkTheme = PreferencesUpdate().getBool(key,def: null) ?? true;
    }
    
    notifyListeners();
  }

  _saveToPrefs()async {
    PreferencesUpdate().updateBool(key, _darkTheme);
  }

}
