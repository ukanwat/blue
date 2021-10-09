// Flutter imports:
import 'package:blue/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:blue/constants/app_colors.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/preferences_update.dart';

// Package imports:

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  bool _darkTheme;

  bool get darkTheme => _darkTheme;

  ThemeNotifier(BuildContext context) {
    _darkTheme = true;
    _loadFromPrefs(context);
  }

  toggleTheme(var value, BuildContext context) {
    _darkTheme = value;
    bool dark = ((value == null) &&
            (SchedulerBinding.instance.window.platformBrightness ==
                Brightness.dark)) ||
        (value == true);
    AppColors.blue = dark ? AppColors.blueDark : AppColors.blueLight;
    AppColors.navBar =
        _darkTheme ? AppColors.navBarDark : AppColors.navBarLight;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            dark ? AppColors.navBarDark : AppColors.navBarLight,
        systemNavigationBarDividerColor:
            dark ? AppColors.navBarDark : AppColors.navBarLight,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark));
    _saveToPrefs();
    notifyListeners();
  }

  _loadFromPrefs(BuildContext context) async {
    if (Boxes.preferenceBox == null) {
      _darkTheme = false;
    } else {
      _darkTheme = PreferencesUpdate().getBool(key, def: null) ??
          (SchedulerBinding.instance.window.platformBrightness ==
              Brightness.dark);
    }

    AppColors.blue = _darkTheme ? AppColors.blueDark : AppColors.blueLight;
    AppColors.navBar =
        _darkTheme ? AppColors.navBarDark : AppColors.navBarLight;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness:
            _darkTheme ? Brightness.light : Brightness.dark,
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            _darkTheme ? AppColors.navBarDark : AppColors.navBarLight,
        systemNavigationBarDividerColor:
            _darkTheme ? AppColors.navBarDark : AppColors.navBarLight,
        systemNavigationBarIconBrightness: Brightness.light));
    notifyListeners();
  }

  _saveToPrefs() async {
    PreferencesUpdate().updateBool(key, _darkTheme);
  }
}
