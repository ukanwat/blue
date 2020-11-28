import 'dart:io';
import 'dart:ui';

import 'package:blue/main.dart';
import 'package:blue/screens/license_screen.dart';
import 'package:blue/screens/settings/about/acknowledgements_screen.dart';
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
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
      'version.release': build. version. release,
      'brand': build.brand,
      'device': build.device,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'userId': currentUser.id,
      'version': 1.0,                 //TODO

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
      appBar: settingsHeader(context, 'Settings',
    
      ),
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 5,
          ),
          settingsSectionTitle(
              icon: Icon(Icons.account_circle), title: 'General'),
          settingsPageNavigationTile(
              context, 'Account', AccountScreen.routeName),
          settingsPageNavigationTile(
              context, 'Appearance', AppearanceScreen.routeName),
          settingsPageNavigationTile(
              context, 'Collections', CollectionsScreen.routeName),
          settingsPageNavigationTile(context, 'Drafts', DraftsScreen.routeName),
          Divider(thickness: 6,
          height: 20,
color: Theme.of(context).canvasColor,
          ),
          settingsSectionTitle(
              icon: Icon(Icons.notifications_active), title: 'Notifications'),
          settingsPageNavigationTile(context, 'Email Notifications',
              EmailNotificationsScreen.routeName),
          settingsPageNavigationTile(
              context, 'Push Notifications', PushNotificationsScreen.routeName),
              Divider(thickness: 6,
          height: 20,color: Theme.of(context).canvasColor,
          ),
          settingsSectionTitle(
            icon: Icon(Icons.category),
            title: 'Advanced Settings',
          ),
          settingsPageNavigationTile(
              context, 'Autoplay', AutoplayScreen.routeName),
                   settingsPageNavigationTile(
              context, 'Font', FontScreen.routeName),
          settingsPageNavigationTile(
              context, 'Content Cache', ContentCacheScreen.routeName),
              Divider(thickness: 6,
          height: 20,color: Theme.of(context).canvasColor,
          ),
          settingsSectionTitle(
            icon: Icon(Icons.person_outline),
            title: 'Privacy',
          ),
          settingsPageNavigationTile(context, 'Safety', SafetyScreen.routeName),
          settingsPageNavigationTile(
              context, 'Activity', ActivityScreen.routeName),
              Divider(thickness: 6,
          height: 20,color: Theme.of(context).canvasColor,
          ),
          settingsSectionTitle(
            icon: Icon(Icons.feedback),
            title: 'Support & Feedback',
          ),
          settingsPageNavigationTile(
              context, 'Give a Suggestion', GiveASuggestionScreen.routeName),
          settingsPageNavigationTile(
              context, 'Report a Bug', ReportABugScreen.routeName),
        settingsActionTile(context, 'Get Help', ()async{
 Map<String, dynamic> deviceData;
    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
      return;
    }
      _deviceData = deviceData;
  

final Email email = Email(
  body:Platform.isIOS? '...\n\nScrible User ID: ${_deviceData['userId']}\nApp version: ${_deviceData['version']}\nDevice: ${_deviceData['name']}\nModel: ${_deviceData['model']}\nManufacturer: ${['manufacturer']}\nOS Version: ${_deviceData['utsname.version']}':
   '...\n\nScrible User ID: ${_deviceData['userId']}\nApp version: ${_deviceData['version']}\nModel: ${_deviceData['model']}\nOS Version: ${_deviceData['version.release']}',
  subject: 'Scrible Support\n[Android]',
  recipients: ['support@scrible.app'],
  isHTML: false,
);

await FlutterEmailSender.send(email);
          
        }),
              Divider(thickness: 6,
          height: 20,color: Theme.of(context).canvasColor,
          ),
          settingsSectionTitle(
            icon: Icon(Icons.info_outline),
            title: 'About',
          ),
                 settingsPageNavigationTile(
              context, 'Terms of Use', TermsOfServiceScreen.routeName),
                settingsPageNavigationTile(
              context, 'Privacy policy', PrivacyPolicyScreen.routeName),
              settingsActionTile(context, 'acknowledgements', 
              (){
                  
                   Navigator.of(context).pushNamed(LicenseScreen.routeName);
              }
              
              ),
          // settingsPageNavigationTile(
          //     context, 'Acknowledgements', AcknowledgementsScreen.routeName),
              Container(
                margin: EdgeInsets.only(
                  top: 8
                ),
                width: double.infinity,
                color: Theme.of(context).canvasColor,
                height: 40, child: Center(child: Text('Scrible v1.0'),),)
        ],
      )),
    );
  }
}
