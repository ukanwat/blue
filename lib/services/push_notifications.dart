import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;
  Future notificationSelected(String payload) async {
    print(payload);
  }

  Future<void> init() async {
    var token = PreferencesUpdate().getString('token');
    print('dev token : $token');
    if (token == null) {
      _firebaseMessaging.getToken().then((deviceToken) {
        PreferencesUpdate().updateString('token', deviceToken, upload: false);
        Hasura.updateUser(token: deviceToken);
      });
    } else {
      Hasura.updateUser(token: token);
    }
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestPermission();
      // _firebaseMessaging.configure(  onMessage: (Map<String, dynamic> message) async {//TODO
      //   print("onMessage: $message");
      // },
      // onBackgroundMessage: myBackgroundMessageHandler,
      // onLaunch: (Map<String, dynamic> message) async {
      //   print("onLaunch: $message");
      // },
      // onResume: (Map<String, dynamic> message) async {
      //   print("onResume: $message");
      // },);

      // For testing purposes print the Firebase Messaging token
      String _token = await _firebaseMessaging.getToken();
      if (_token != PreferencesUpdate().getString('token')) {
        Hasura.updateUser(token: _token);
      }
      print("FirebaseMessaging token: $_token");

      _initialized = true;
    }
  }
}
