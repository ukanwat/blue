import 'package:blue/main.dart';

class PreferencesUpdate {
  updateBool(
    String key,
    bool value,
  ) {
    preferences.setBool(key, value);
  }

  updateString(
    String key,
    String value,
  ) {
    preferences.setString(key, value);
  }

  bool containsInStringList(
    String key,
    String value,
  ) {
    var _list = preferences.getStringList(
      key,
    );
    if (_list == null) {
      _list = [];
    }
    return _list.contains(value);
  }

  updateStringList(
    String key,
    List<String> value,
  ) {
    preferences.setStringList(key, value);
  }

  removeStringFromList(
    String key,
    String value,
  ) {
    List _list = preferences.getStringList(key);
    if (_list != null) {
      _list.remove(value);
      preferences.setStringList(key, _list);
    } else {
      preferences.setStringList(key, []);
    }
  }

  addStringToList(
    String key,
    String value,
  ) {
    List<String> _list = preferences.getStringList(key);
    if (_list == null) _list = [];
    _list.add(value);
    preferences.setStringList(key, _list);
  }

  String getString(
    String key,
  ) {
    return preferences.getString(key);
  }

  List<String> getStringList(
    String key,
  ) {
    List<String> _list = preferences.getStringList(key);
    if (_list == null) {
      return [];
    }
    return _list;
  }

  bool getBool(String key, {bool def}) {
    if (def != null) {
      if (preferences.getBool(key) == null) return def;
    }

    return preferences.getBool(key);
  }
}
