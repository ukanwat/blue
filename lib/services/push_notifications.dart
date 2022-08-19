// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:blue/services/notification_functions.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/dialogs/empty_dialog.dart';
import 'package:blue/widgets/dialogs/show_dialog.dart';

String messagToken;
Future<File> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return file;
}

Future<void> _showBigPictureNotification(
    String url, RemoteNotification notification) async {
  final File file = await _downloadAndSaveFile(url, 'bigPicture');
  Im.Image image = Im.copyResize(
    Im.decodeImage(file.readAsBytesSync()),
    width: 48,
  );
  Im.Image image2 = Im.copyResizeCropSquare(image, 48);
  final tempDir = await getTemporaryDirectory();
  final path = tempDir.path;
  String fileName = Uuid().v4();
  final compressedImageFile = File('$path/img_$fileName.jpg')
    ..writeAsBytesSync(Im.encodeJpg(image2, quality: 100));
  final BigPictureStyleInformation bigPictureStyleInformation =
      BigPictureStyleInformation(FilePathAndroidBitmap(file.path),
          largeIcon: FilePathAndroidBitmap(compressedImageFile.path),
          contentTitle: 'overridden <b>big</b> content title',
          htmlFormatContentTitle: true,
          summaryText: 'summary <i>text</i>',
          htmlFormatSummaryText: true);
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(channel.id, channel.name, channel.description,
          styleInformation: bigPictureStyleInformation);
  final NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(notification.hashCode,
      notification.title, notification.body, platformChannelSpecifics);
}

bool userSigningUp = false;
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  RemoteNotification notification = message.notification;
  AndroidNotification android = message.notification?.android;
  AppleNotification apple = message.notification?.apple;
  String url = android.imageUrl;

  var initialzationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initialzationSettingsiOS = IOSInitializationSettings(
    requestSoundPermission: true,
    requestAlertPermission: true,
    defaultPresentAlert: true,
    defaultPresentSound: true,
    defaultPresentBadge: true,
  );
  var initializationSettings = InitializationSettings(
      android: initialzationSettingsAndroid, iOS: initialzationSettingsiOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  if (notification != null && android != null) {
    if (url == null || url == '') {
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
    } else {
      _showBigPictureNotification(url, notification);
    }
  }

  if (notification != null && apple != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        iOS: IOSNotificationDetails(
          presentSound: true,
          presentAlert: true,
        ),
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channel.description,
          icon: android?.smallIcon,
        ),
      ),
    );
  }
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
    bool agree =
        await PreferencesUpdate().getFuture('push_notif_agree', online: true) ??
            true;

    if (!agree) {
      await showDialog(
          context: Get.context,
          builder: (context) {
            return ShowDialog(
              description: 'Would you like to receive push notifications?',
              title: 'Push Notifications',
              middleButtonText: 'No',
              topButtonText: 'Yes',
              middleButtonFunction: () {
                Navigator.pop(context);
                ret = true;
              },
              topButtonFunction: () {
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
    var initialzationSettingsiOS = IOSInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
    );
    var initializationSettings = InitializationSettings(
        android: initialzationSettingsAndroid, iOS: initialzationSettingsiOS);
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification notification = message.notification;
    //   AndroidNotification android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     flutterLocalNotificationsPlugin.show(
    //       notification.hashCode,
    //       notification.title,
    //       notification.body,
    //       NotificationDetails(
    //           android: AndroidNotificationDetails(
    //             channel.id,
    //             channel.name,
    //             channel.description,
    //             //      one that already exists in example app.
    //             icon: 'launch_background',
    //           ),
    //           iOS: IOSNotificationDetails()),
    //     );
    //   }
    // });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      String action = message.data['action'];
      int sourceId = message.data['source_id'];
      if (action == 'follow') {
        NotifFunctions.goToProfile(sourceId, Get.context);
      }
      if (action == 'comment') {
        NotifFunctions.goToComment(sourceId, Get.context);
      }
      if (action == 'comment_reply') {
        NotifFunctions.goToCommentReply(sourceId, Get.context);
      }
      if (action == 'upvote') {
        NotifFunctions.goToPost(sourceId, Get.context);
      }
    });
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // RemoteNotification notification = message.notification;
      // AndroidNotification android = message.notification?.android;
      // String url = android.imageUrl;
      // if (notification != null && android != null) {
      //   if (url == null || url == '') {
      //     flutterLocalNotificationsPlugin.show(
      //         notification.hashCode,
      //         notification.title,
      //         notification.body,
      //         NotificationDetails(
      //           android: AndroidNotificationDetails(
      //             channel.id,
      //             channel.name,
      //             channel.description,
      //             icon: android?.smallIcon,
      //           ),
      //         ));
      //   } else {
      //     _showBigPictureNotification(url, notification);
      //   }
      // }
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
        print(deviceToken);
        Hasura.updateUser(token: deviceToken);
      });
    } catch (e) {}
  }
}
