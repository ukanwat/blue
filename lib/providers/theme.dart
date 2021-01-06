// Flutter imports:
import 'package:blue/services/preferences_update.dart';
import 'package:flutter/foundation.dart';
import 'package:blue/services/boxes.dart';
import 'package:flutter/material.dart';
// Package imports:

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  bool _darkTheme;

  bool get darkTheme => _darkTheme;
  
  ThemeNotifier(BuildContext context) {
    _darkTheme = true;
    _loadFromPrefs(context);
  }

  toggleTheme(var value ) {
    _darkTheme = value;
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
