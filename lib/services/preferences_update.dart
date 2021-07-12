// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/boxes.dart';
import 'hasura.dart';

class PreferencesUpdate {
  updateBool(String key, bool value, {bool upload}) {
    if (upload != null ? upload : false) {
      uploadValue(key, value, false);
    }
    Boxes.preferenceBox.put(key, value);
    Hasura.updatePreferences(key, value);
  }

  getValue(String key) {
    return Boxes.preferenceBox.get(key);
  }

  uploadValue(String key, dynamic value, bool str, {bool update}) async {
    await Hasura.updatePreferences(key, value, string: str);
    if (update == true) {
      Boxes.preferenceBox.put(key, value);
    }
  }

  updateString(
    String key,
    String value, {
    bool upload,
  }) async {
    if (upload == true) {
      await Hasura.updatePreferences(key, value, string: true);
    }
    await Boxes.preferenceBox.put(key, value);
  }

  bool containsInList(
    var key,
    dynamic value,
  ) {
    List _list = Boxes.preferenceBox.get(
      key,
    );
    if (_list == null) {
      _list = [];
    }

    return _list.contains(value);
  }

  updateStringList(
    String key,
    List<dynamic> value,
  ) {
    List _list = Boxes.preferenceBox.get(
      key,
    );
    if (_list == null) {
      _list = [];
    }

    List list = _list + value;

    Boxes.preferenceBox.put(key, list);
  }

  setStringList(
    String key,
    List<dynamic> value,
  ) {
    Boxes.preferenceBox.put(key, value);
  }

  removeFromList(
    var key,
    dynamic value,
  ) async {
    List _list = Boxes.preferenceBox.get(key);
    if (_list != null) {
      _list.remove(value);
      await Boxes.preferenceBox.put(key, _list);
    } else {
      await Boxes.preferenceBox.put(key, []);
    }
  }

  addToList(
    var key,
    dynamic value,
  ) {
    List<dynamic> _list = Boxes.preferenceBox.get(key);

    if (_list == null) {
      _list = <dynamic>[];
    }
    if (!_list.contains(value)) {
      _list.add(value);
    }

    Boxes.preferenceBox.put(key, _list);
  }

  isListEmpty(String key) {
    List<dynamic> _list = Boxes.preferenceBox.get(key);
    if (_list == null) {
      _list = [];
    }
    if (_list.length == 0) {
      return true;
    }
    Boxes.preferenceBox.put(key, _list);
    return false;
  }

  String getString(
    String key,
  ) {
    if (!Boxes.preferenceBox.containsKey(key)) {
      return null;
    }
    return Boxes.preferenceBox.get(key);
  }

  getFuture(String key, {bool online}) async {
    if (!Boxes.preferenceBox.containsKey(key) || online == true) {
      return await Hasura.getPreferences(key);
    }

    return Boxes.preferenceBox.get(key);
  }

  List<dynamic> getStringList(
    String key,
  ) {
    List<dynamic> _list = Boxes.preferenceBox.get(key);
    if (_list == null) {
      return [];
    }
    return _list;
  }

  getSetValue(String key) async {
    dynamic value = await Hasura.getPreferences(key);
    Boxes.preferenceBox.put(key, value);
    return value;
  }

  bool getBool(String key, {bool def}) {
    if (def != null) {
      if (Boxes.preferenceBox.get(key) == null) return def;
    }

    return Boxes.preferenceBox.get(key);
  }

  setFollowings() async {
    List followings = await Hasura.getFollowingIds();
    Map map = {for (var item in followings) item['following_id']: true};
    await Boxes.followingBox.putAll(map);
  }

  setSaves() async {
    List saves = await Hasura.getSaveIds();
    Map map = {for (var item in saves) item['post']['post_id']: true};
    await Boxes.saveBox.putAll(map);
  }
}
