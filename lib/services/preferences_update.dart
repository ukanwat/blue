// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/boxes.dart';

import 'hasura.dart';

class PreferencesUpdate {
  updateBool(
    String key,
    bool value, {
    bool upload,
  }) {
    if (upload != null ? upload : false) {
      preferencesRef.doc(currentUser.id).update({key: value});
    }
    Boxes.preferenceBox.put(key, value);
      Hasura.updatePreferences(key,value);
  }

  updateString(
    String key,
    String value, {
    bool upload,
  }) async{
    if (upload == true) {
  await Hasura.updatePreferences(key, value);

    }
   await Boxes.preferenceBox.put(key, value);
    
  }

  bool containsInList(
    String key,
    dynamic value,
  ) {
    var _list = Boxes.preferenceBox.get(
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
     Boxes.preferenceBox.put(key, value);
  }

  removeStringFromList(
    String key,
    String value,
  ) async {
    List _list =  Boxes.preferenceBox.get(key);
    if (_list != null) {
      _list.remove(value);
      await  Boxes.preferenceBox.put(key, _list);
    } else {
      await  Boxes.preferenceBox.put(key, []);
    }
  }

  addStringToList(
    String key,
    String value,
  ) {
    List<String> _list =  Boxes.preferenceBox.get(key);
    if (_list == null) _list = [];
    _list.add(value);
     Boxes.preferenceBox.put(key, _list);
  }

  String getString(
    String key,
  ) {
    if(!Boxes.preferenceBox.containsKey('token')){
         return null;
    }
    return  Boxes.preferenceBox.get(key);
  }

  List<String> getStringList(
    String key,
  ) {
    List<String> _list =  Boxes.preferenceBox.get(key);
    if (_list == null) {
      return [];
    }
    return _list;
  }
  getSetValue(String key)async{
    dynamic value =await Hasura.getPreferences(key);
     Boxes.preferenceBox.put(key, value);
     return value;
  }
  bool getBool(String key, {bool def}) {
    if (def != null) {
      if ( Boxes.preferenceBox.get(key) == null) return def;
    }

    return  Boxes.preferenceBox.get(key);
  }
}
