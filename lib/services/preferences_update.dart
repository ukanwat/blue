// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/boxes.dart';

import 'hasura.dart';

class PreferencesUpdate {
  updateBool(
    String key,
    bool value,{ bool upload}) {
    if (upload != null ? upload : false) {
     uploadValue(key, value, false);
    }
    Boxes.preferenceBox.put(key, value);
      Hasura.updatePreferences(key,value);
  }
  uploadValue(String key, dynamic value,bool str )async{
     await Hasura.updatePreferences(key, value,string: str);
  }

  updateString(
    String key,
    String value, {
    bool upload,
  }) async{
    if (upload == true) {
  await Hasura.updatePreferences(key, value,string: true);
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

  removeFromList(
    String key,
    dynamic value,
  ) async {
    List _list =  Boxes.preferenceBox.get(key);
    if (_list != null) {
      _list.remove(value);
      await  Boxes.preferenceBox.put(key, _list);
    } else {
      await  Boxes.preferenceBox.put(key, []);
    }
  }

  addToList(
    String key,
    dynamic value,
  ) {
    List<dynamic> _list =  Boxes.preferenceBox.get(key);
    if (_list == null) {_list = [];}
    if(!_list.contains(value)){
_list.add(value);
    }
    
     Boxes.preferenceBox.put(key, _list);
  }

  String getString(
    String key,
  ) {
    if(!Boxes.preferenceBox.containsKey(key)){
         return null;
    }
    return  Boxes.preferenceBox.get(key);
  }

  getFuture(String key)async{
 if(!Boxes.preferenceBox.containsKey(key)){
    return await Hasura.getPreferences(key);
       
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
