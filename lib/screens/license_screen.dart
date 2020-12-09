import 'dart:async';
import 'dart:developer' show Timeline, Flow;
import 'package:blue/screens/package_licenses_screen.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide Flow;
import 'package:flutter/material.dart' hide Flow;

class LicenseScreen extends StatefulWidget {
  static const routeName = 'license';
  @override
  _LicenseScreenState createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  @override
  void initState() {
    super.initState();
    _initLicenses();
  }

  Map<String, List> licenses = {};

  final List<Widget> _licenses = <Widget>[];
  bool _loaded = false;

  Future<void> _initLicenses() async {
    int debugFlowId = -1;
    assert(() {
      final Flow flow = Flow.begin();
      Timeline.timeSync('_initLicenses()', () {}, flow: flow);
      debugFlowId = flow.id;
      return true;
    }());
    await for (final LicenseEntry license in LicenseRegistry.licenses) {
      if (!mounted) {
        return;
      }
      assert(() {
        Timeline.timeSync('_initLicenses()', () {},
            flow: Flow.step(debugFlowId));
        return true;
      }());
      final List<LicenseParagraph> paragraphs =
          await SchedulerBinding.instance.scheduleTask<List<LicenseParagraph>>(
        license.paragraphs.toList,
        Priority.animation,
        debugLabel: 'License',
      );

      final String licenseName = license.packages.join(', ');

      if (licenses[licenseName] != null) {
        licenses[licenseName].add(paragraphs);
      } else {
        licenses[licenseName] = [paragraphs];
      }

    
    }
    if (!mounted) {
      return;
    }
    setState(() {
      licenses.forEach((key, value) {
        _licenses.add(InkWell(
          onTap: () {
            Navigator.of(context)
                .pushNamed(PackageLicensesScreen.routeName, arguments: {
              'name': key,
              'licenses': value,
            });
          },
          child: Container(
            decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(width: 0.3, color: Colors.grey))),
            padding: EdgeInsets.symmetric(vertical: 20),
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                    key,
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(
                      color: Theme.of(context).iconTheme.color,              //TODO
                        fontWeight: FontWeight.w500, fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                                  ),
                ),
                Text(
                  
                  value.length > 1
                    ? '${value.length} Licenses'
                    : '            ')
              ],
            ),
          ),
        ));
      });
      _loaded = true;
    });

    assert(() {
      Timeline.timeSync('Build scheduled', () {}, flow: Flow.end(debugFlowId));
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final String name = 'Scrible';
    final String version = 'Build Version 1.0';
    final Widget icon = Container(
      color: Colors.blue,
      width: 100,
      height: 100,
    );
    final String applicationLegalese = '© 2020 Scrible. All Rights Reserved';

    return Scaffold(
      appBar: settingsHeader(context, 'Open Source Licenses'),
      // All of the licenses page text is English. We don't want localized text
      // or text direction.
      body: Localizations.override(
        locale: const Locale('en', 'US'),
        context: context,
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.caption,
          child: SafeArea(
            bottom: false,
            child: Scrollbar(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
                children: <Widget>[
                  Text(name,
                      style: Theme.of(context).textTheme.headline5,
                      
                      textAlign: TextAlign.center),
                  if (icon != null)
                    IconTheme(data: Theme.of(context).iconTheme, child: icon),
                       Container(height: 18.0),
                  Text(version,
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center),
                  Container(height: 18.0),
                  Text(applicationLegalese,
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.center),
                  Container(height: 18.0),
                  ..._licenses,
                  if (!_loaded)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
