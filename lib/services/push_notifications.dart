import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsManager {

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
     var token =   PreferencesUpdate().getString('token');
     if(token == null){
       _firebaseMessaging.getToken().then((deviceToken) {
       PreferencesUpdate().updateString('token', deviceToken,upload: false);
       Hasura.updateUser(token: deviceToken);
       });
     }
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      // For testing purposes print the Firebase Messaging token
      String _token = await _firebaseMessaging.getToken();
      if(_token != PreferencesUpdate().getString('token')){
        Hasura.updateUser(token: _token);
      }
      print("FirebaseMessaging token: $_token");
      
      _initialized = true;
    }
  }
}