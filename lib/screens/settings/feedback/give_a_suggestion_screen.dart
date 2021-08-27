import 'package:blue/constants/app_colors.dart';
import 'package:universal_platform/universal_platform.dart';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter/services.dart';

// Package imports:
import 'package:device_info/device_info.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';

class GiveASuggestionScreen extends StatefulWidget {
  static const routeName = 'give-a-suggestion';
  @override
  _GiveASuggestionScreenState createState() => _GiveASuggestionScreenState();
}

class _GiveASuggestionScreenState extends State<GiveASuggestionScreen> {
  TextEditingController suggestionController = TextEditingController();
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      if (UniversalPlatform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (UniversalPlatform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.release': build.version.release,
      'brand': build.brand,
      'device': build.device,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'platform': 'android',
      'userId': currentUser.userId,
      'version': 1.0, //TODO

      'resolution':
          '${window.physicalSize.height} X ${window.physicalSize.width}'
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'platform': 'iOS',
      'userId': currentUser.userId,
      'version': 1.0, //TODO

      'resolution':
          '${window.physicalSize.height} X ${window.physicalSize.width}'
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Give Suggestion'),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: TextField(
              controller: suggestionController,
              style: TextStyle(
                  fontSize: 18, color: Theme.of(context).iconTheme.color),
              maxLines: 10,
              maxLength: 2000,
              minLines: 10,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 15, left: 10, right: 10),
                hintText: 'Suggestion details...',
                counter: Container(),
                hintStyle: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).iconTheme.color.withOpacity(0.8)),
                fillColor: Theme.of(context).cardColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    width: 0,
                    color: Theme.of(context).cardColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    width: 0,
                    color: Theme.of(context).cardColor,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _deviceData['suggestion'] = suggestionController.text;
              Hasura.insertFeedback(Feedback.suggestion, _deviceData);
              Navigator.of(context).pop();
              snackbar('Thanks for submitting the suggestion.', context);
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(
                vertical: 15,
              ),
              child: Center(
                child: Text(
                  'Submit',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
            ),
          ),
          Container(
            width: double.infinity,
            child: Center(
              child: Text(
                'Your feedback will be used to help us better understand your experience and improve the app features.',
                style: TextStyle(fontSize: 12, color: Colors.grey //TODO
                    ),
              ),
            ),
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 14),
          ),
        ],
      ),
    );
  }
}
