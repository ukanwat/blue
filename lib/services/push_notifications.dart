import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/empty_dialog.dart';
import 'package:blue/widgets/show_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

String messagToken;

bool userSigningUp = false;
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  flutterLocalNotificationsPlugin.show(
      message.data.hashCode,
      message.data['title'],
      message.data['body'],
      NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channel.description,
          ),
          iOS: IOSNotificationDetails()));
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  initMessage() async {
    getToken();
    bool ret;
    bool agree = await PreferencesUpdate().getFuture(
      'push_notif_agree',
    );
    await PreferencesUpdate().updateBool('push_notif_agree', agree);
    if (!agree) {
      await showDialog(
          context: Get.context,
          builder: (context) {
            return ShowDialog(
              description: 'Would you like to receive push notifications?',
              title: 'Push Notifications',
              leftButtonText: 'No',
              rightButtonText: 'Yes',
              leftButtonFunction: () {
                Navigator.pop(context);
                ret = true;
              },
              rightButtonFunction: () {
                Navigator.pop(context);
                PreferencesUpdate()
                    .uploadValue('push_notif_agree', true, false);
              },
            );
          });

      await PreferencesUpdate().uploadValue('push_notif_agree', true, false);
    }

    if (ret == true) {
      return;
    }

    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initialzationSettingsiOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initialzationSettingsAndroid, iOS: initialzationSettingsiOS);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
              iOS: IOSNotificationDetails()),
        );
      }
    });
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: android?.smallIcon,
              ),
            ));
      }
    });
    getToken();
  }

  initNotif() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future notificationSelected(String payload) async {}

  Future<void> getToken() async {
    try {
      await _firebaseMessaging.getToken().then((deviceToken) {
        PreferencesUpdate().updateString('token', deviceToken);

        Hasura.updateUser(token: deviceToken);
      });
    } catch (e) {}
  }
}
