import 'dart:io';
import 'dart:ui';
import 'package:blue/main.dart';
import 'package:blue/screens/license_screen.dart';
import 'package:blue/screens/settings/about/privacy_policy_screen.dart';
import 'package:blue/screens/settings/about/terms_of_service_screen.dart';
import 'package:blue/screens/settings/advanced_settings/font_screen.dart';
import 'package:blue/screens/settings/general/account_screen.dart';
import 'package:blue/screens/settings/advanced_settings/autoplay_screen.dart';
import 'package:blue/screens/settings/advanced_settings/content_cache_screen.dart';
import 'package:blue/screens/settings/feedback/give_a_suggestion_screen.dart';
import 'package:blue/screens/settings/feedback/report_a_bug_screen.dart';
import 'package:blue/screens/settings/general/appearance_screen.dart';
import 'package:blue/screens/settings/general/collections_screen.dart';
import 'package:blue/screens/settings/general/drafts_screen.dart';
import 'package:blue/screens/settings/notification/email_notifications_screen.dart';
import 'package:blue/screens/settings/notification/push_notifications_screen.dart';
import 'package:blue/screens/settings/privacy/activity_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screen.dart';
import 'package:device_info/device_info.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
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
              Container(
                height: 5,
              ),
              settingsSectionTitle(
                  'General', Icon(FluentIcons.content_settings_20_regular,color: Colors.blueAccent,), context),
              settingsPageNavigationTile(
                  context, 'Account', AccountScreen.routeName),
              settingsPageNavigationTile(
                  context, 'Appearance', AppearanceScreen.routeName),
              settingsPageNavigationTile(
                  context, 'Collections', CollectionsScreen.routeName),
              settingsPageNavigationTile(
                  context, 'Drafts', DraftsScreen.routeName),
              Divider(
                thickness: 6,
                height: 20,
                color: Theme.of(context).canvasColor,
              ),
              settingsSectionTitle(
                  'Notifications', Icon(FluentIcons.alert_20_regular,color: Colors.blueAccent,), context),
              settingsPageNavigationTile(context, 'Email Notifications',
                  EmailNotificationsScreen.routeName),
              settingsPageNavigationTile(context, 'Push Notifications',
                  PushNotificationsScreen.routeName),
              Divider(
                thickness: 6,
                height: 20,
                color: Theme.of(context).canvasColor,
              ),
              settingsSectionTitle(
                  'Advanced Settings', Icon(FluentIcons.more_circle_20_regular,color: Colors.blueAccent,), context),
              settingsPageNavigationTile(
                  context, 'Autoplay', AutoplayScreen.routeName),
              settingsPageNavigationTile(context, 'Font', FontScreen.routeName),
              
              settingsPageNavigationTile(context, 'Content Cache',ContentCacheScreen.routeName),
              
              Divider(
                thickness: 6,
                height: 20,
                color: Theme.of(context).canvasColor,
              ),
              settingsSectionTitle(
                  'Privacy', Icon(FluentIcons.person_20_regular,color: Colors.blueAccent,), context),
              settingsPageNavigationTile(
                  context, 'Safety', SafetyScreen.routeName),
              settingsPageNavigationTile(
                  context, 'Activity', ActivityScreen.routeName),
              Divider(
                thickness: 6,
                height: 20,
                color: Theme.of(context).canvasColor,
              ),
              settingsSectionTitle(
                  'Support & Feedback', Icon(FluentIcons.person_support_20_regular,color: Colors.blueAccent,), context),
              settingsActionTile(context, 'Give a Suggestion', () {
                Navigator.of(context)
                    .pushNamed(GiveASuggestionScreen.routeName);
              }, FluentIcons.person_feedback_24_regular),
              settingsActionTile(
                context,
                'Report a Bug',
               () {
                Navigator.of(context)
                    .pushNamed(ReportABugScreen.routeName);
              },FluentIcons.bug_24_regular
              ),
              settingsActionTile(context, 'Get Help', () async {
                Map<String, dynamic> deviceData;
                try {
                  if (Platform.isAndroid) {
                    deviceData = _readAndroidBuildData(
                        await deviceInfoPlugin.androidInfo);
                  } else if (Platform.isIOS) {
                    deviceData =
                        _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
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
                      ? '...\n\nScrible User ID: ${_deviceData['userId']}\nApp version: ${_deviceData['version']}\nDevice: ${_deviceData['name']}\nModel: ${_deviceData['model']}\nManufacturer: ${[
                          'manufacturer'
                        ]}\nOS Version: ${_deviceData['utsname.version']}'
                      : '...\n\nScrible User ID: ${_deviceData['userId']}\nApp version: ${_deviceData['version']}\nModel: ${_deviceData['model']}\nOS Version: ${_deviceData['version.release']}',
                  subject: 'Scrible Support\n[Android]',
                  recipients: ['support@scrible.app'],
                  isHTML: false,
                );

                await FlutterEmailSender.send(email);
              }, FluentIcons.chat_help_24_regular),
              Divider(
                thickness: 6,
                height: 20,
                color: Theme.of(context).canvasColor,
              ),
              settingsSectionTitle('About', Icon(FluentIcons.info_24_regular,color: Colors.blueAccent,), context),
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
                Navigator.of(context).pushNamed(PrivacyPolicyScreen.routeName);
              }, FluentIcons.lock_24_regular),
              settingsActionTile(context, 'acknowledgements', () {
                Navigator.of(context).pushNamed(LicenseScreen.routeName);
              }, FluentIcons.ribbon_24_regular),
              Container(
                margin: EdgeInsets.only(top: 8),
                width: double.infinity,
                color: Theme.of(context).canvasColor,
                height: 40,
                child: Center(
                  child: Text('ABC v1.0'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
