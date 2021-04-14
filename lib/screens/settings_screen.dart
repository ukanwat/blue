// Dart imports:
import 'dart:io';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:device_info/device_info.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/license_screen.dart';
import 'package:blue/screens/settings/about/privacy_policy_screen.dart';
import 'package:blue/screens/settings/about/terms_of_service_screen.dart';
import 'package:blue/screens/settings/feedback/give_a_suggestion_screen.dart';
import 'package:blue/screens/settings/feedback/report_a_bug_screen.dart';
import 'package:blue/screens/settings/general/account_screen.dart';
import 'package:blue/screens/settings/general/appearance_screen.dart';
import 'package:blue/screens/settings/general/collections_screen.dart';
import 'package:blue/screens/settings/general/drafts_screen.dart';
import 'package:blue/screens/settings/notification/email_notifications_screen.dart';
import 'package:blue/screens/settings/notification/push_notifications_screen.dart';
import 'package:blue/screens/settings/privacy/activity_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screen.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = 'settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _deviceData;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.release': build.version.release,
      'brand': build.brand,
      'device': build.device,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'userId': currentUser.id,
      'version': 1.0, //TODO
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'utsname.release': data.utsname.release,
      'utsname.version': data.utsname.version,
      'userId': currentUser.id,
      'version': 1.0,
      //TODO
    };
  }

  @override
  Widget build(BuildContext context) {
    bool dark = Theme.of(context).iconTheme.color == Colors.white;
    return Scaffold(
      backgroundColor: dark
          ? Theme.of(context).backgroundColor
          : Theme.of(context).canvasColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  color: dark
                      ? Theme.of(context).backgroundColor
                      : Theme.of(context).canvasColor,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          FluentIcons.chevron_left_24_filled,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontFamily: 'Techna Sans Regular',
                          fontSize: 24,
                        ),
                      ),
                    ],
                  )),
              settingsSectionTitle(
                  'General',
                  Icon(
                    FluentIcons.content_settings_20_regular,
                    color: Colors.blueAccent,
                  ),
                  context),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  color: dark
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).backgroundColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        settingsPageNavigationTile(
                            context, 'Account', AccountScreen.routeName),
                        settingsPageNavigationTile(
                            context, 'Appearance', AppearanceScreen.routeName),
                        settingsPageNavigationTile(context, 'Collections',
                            CollectionsScreen.routeName),
                        settingsPageNavigationTile(
                            context, 'Drafts', DraftsScreen.routeName,
                            removeBorder: true),
                      ],
                    ),
                  ),
                ),
              ),

              settingsSectionTitle(
                  'Notifications',
                  Icon(
                    FluentIcons.alert_20_regular,
                    color: Colors.blueAccent,
                  ),
                  context),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  color: dark
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).backgroundColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        settingsPageNavigationTile(
                            context,
                            'Email Notifications',
                            EmailNotificationsScreen.routeName),
                        settingsPageNavigationTile(
                            context,
                            'Push Notifications',
                            PushNotificationsScreen.routeName,
                            removeBorder: true),
                      ],
                    ),
                  ),
                ),
              ),

              settingsSectionTitle(
                  'Privacy',
                  Icon(
                    FluentIcons.person_20_regular,
                    color: Colors.blueAccent,
                  ),
                  context),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  color: dark
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).backgroundColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        settingsPageNavigationTile(
                            context, 'Safety', SafetyScreen.routeName),
                        settingsPageNavigationTile(
                            context, 'Activity', ActivityScreen.routeName,
                            removeBorder: true),
                      ],
                    ),
                  ),
                ),
              ),

              // Divider(
              //   thickness: 6,
              //   height: 20,
              //   color: Theme.of(context).canvasColor,
              // ),
              settingsSectionTitle(
                  'Support & Feedback',
                  Icon(
                    FluentIcons.person_support_20_regular,
                    color: Colors.blueAccent,
                  ),
                  context),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  color: dark
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).backgroundColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        settingsActionTile(context, 'Give a Suggestion', () {
                          Navigator.of(context)
                              .pushNamed(GiveASuggestionScreen.routeName);
                        }, FluentIcons.person_feedback_24_regular),
                        settingsActionTile(context, 'Report a Bug', () {
                          Navigator.of(context)
                              .pushNamed(ReportABugScreen.routeName);
                        }, FluentIcons.bug_24_regular),
                        settingsActionTile(context, 'Get Help', () async {
                          Map<String, dynamic> deviceData;
                          try {
                            if (Platform.isAndroid) {
                              deviceData = _readAndroidBuildData(
                                  await deviceInfoPlugin.androidInfo);
                            } else if (Platform.isIOS) {
                              deviceData = _readIosDeviceInfo(
                                  await deviceInfoPlugin.iosInfo);
                            }
                          } on PlatformException {
                            deviceData = <String, dynamic>{
                              'Error:': 'Failed to get platform version.'
                            };
                            return;
                          }
                          _deviceData = deviceData;

                          final Email email = Email(
                            body: Platform.isIOS
                                ? '...\n\nStark User ID: ${_deviceData['userId']}\nApp version: ${_deviceData['version']}\nDevice: ${_deviceData['name']}\nModel: ${_deviceData['model']}\nManufacturer: ${[
                                    'manufacturer'
                                  ]}\nOS Version: ${_deviceData['utsname.version']}'
                                : '...\n\nStark User ID: ${_deviceData['userId']}\nApp version: ${_deviceData['version']}\nModel: ${_deviceData['model']}\nOS Version: ${_deviceData['version.release']}',
                            subject: 'Stark Support\n[Android]',
                            recipients: ['support@stark.social'],
                            isHTML: false,
                          );

                          await FlutterEmailSender.send(email);
                        }, FluentIcons.chat_help_24_regular,
                            removeBorder: true),
                      ],
                    ),
                  ),
                ),
              ),
              settingsSectionTitle(
                  'About',
                  Icon(
                    FluentIcons.info_24_regular,
                    color: Colors.blueAccent,
                  ),
                  context),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  color: dark
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).backgroundColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        settingsActionTile(
                          context,
                          'Terms of Use',
                          () {
                            Navigator.of(context)
                                .pushNamed(TermsOfServiceScreen.routeName);
                          },
                          FluentIcons.textbox_24_regular,
                        ),
                        settingsActionTile(context, 'Privacy policy', () {
                          Navigator.of(context)
                              .pushNamed(PrivacyPolicyScreen.routeName);
                        }, FlutterIcons.lock_mco),
                        settingsActionTile(context, 'acknowledgements', () {
                          Navigator.of(context)
                              .pushNamed(LicenseScreen.routeName);
                        }, FluentIcons.ribbon_24_regular, removeBorder: true),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.only(top: 8),
                width: double.infinity,
                color: dark
                    ? Theme.of(context).backgroundColor
                    : Theme.of(context).canvasColor,
                height: 40,
                child: Center(
                  child: Text('v1.0'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
