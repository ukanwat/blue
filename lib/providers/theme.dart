// Flutter imports:
import 'package:blue/services/preferences_update.dart';
import 'package:flutter/foundation.dart';
import 'package:blue/services/boxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
    bool dark = ((value == null)&&  (SchedulerBinding.instance.window.platformBrightness == Brightness.dark))  || (value == true);
     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
       statusBarIconBrightness: dark? Brightness.light: Brightness.dark,
       statusBarBrightness: Brightness.light,
       statusBarColor:dark? Color.fromRGBO(180, 180, 180, 1): Color.fromRGBO(240, 240, 240, 1),
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
