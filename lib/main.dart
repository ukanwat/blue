import 'package:blue/screens/all_topics_screen.dart';
import 'package:blue/screens/post_settings_screen.dart';
import 'package:blue/screens/settings/about/acknowledgements_screen.dart';
import 'package:blue/screens/settings/advanced_settings/autoplay_screen.dart';
import 'package:blue/screens/settings/advanced_settings/content_cache_screen.dart';
import 'package:blue/screens/settings/advanced_settings/gestures_screen.dart';
import 'package:blue/screens/settings/feedback/give_a_suggestion_screen.dart';
import 'package:blue/screens/settings/feedback/report_a_bug_screen.dart';
import 'package:blue/screens/settings/general/account_screen.dart';
import 'package:blue/screens/settings/general/collections_screen.dart';
import 'package:blue/screens/settings/general/drafts_screen.dart';
import 'package:blue/screens/settings/general/personalize_screen.dart';
import 'package:blue/screens/settings/notification/email_notifications_screen.dart';
import 'package:blue/screens/settings/notification/push_notifications_screen.dart';
import 'package:blue/screens/settings/notification/sound_screen.dart';
import 'package:blue/screens/settings/privacy/activity_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screen.dart';
import 'package:blue/screens/topic_posts_screen.dart';
import 'package:flutter/material.dart';

import 'package:blue/screens/chat_messages_screen.dart';
import './screens/search_screen.dart';
import './screens/edit_profile_screen.dart';
import './screens/home.dart';
import './screens/post_screen.dart';
import './screens/comments_screen.dart';
import './screens/setttings_screen.dart';

void main() {
  // Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
  //   print("Timestamps enabled in snapshots\n");
  // }, onError: (_) {
  //   print("Error enabling timestamps in snapshots\n");
  // });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Blue',
        theme: ThemeData(
            primaryColor: Color.fromRGBO(3, 23, 84, 1),
            accentColor: Color.fromRGBO(200, 200, 200, 1)),
        home: Home(),
        routes: {
          SearchScreen.routeName: (ctx) => SearchScreen(),
          EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
          PostScreen.routeName: (ctx) => PostScreen(),
          CommentsScreen.routeName: (ctx) => CommentsScreen(),
          ChatMessagesScreen.routeName: (ctx) => ChatMessagesScreen(),
          PostSettingsScreen.routeName: (ctx) => PostSettingsScreen(),
          TopicPostsScreen.routeName: (ctx) => TopicPostsScreen(),
          AllTopicsScreen.routeName: (ctx) => AllTopicsScreen(),
          SettingsScreen.routeName: (ctx) => SettingsScreen(),
          
          AccountScreen.routeName: (ctx) => AccountScreen(),
          PersonalizeScreen.routeName: (ctx) => PersonalizeScreen(),
          CollectionsScreen.routeName: (ctx) => CollectionsScreen(),
          DraftsScreen.routeName: (ctx) => DraftsScreen(),
          PushNotificationsScreen.routeName: (ctx) => PushNotificationsScreen(),
          EmailNotificationsScreen.routeName: (ctx) => EmailNotificationsScreen(),
          SoundScreen.routeName: (ctx) => SoundScreen(),
          AutoplayScreen.routeName: (ctx) => AutoplayScreen(),
          ContentCacheScreen.routeName: (ctx) => ContentCacheScreen(),
          GesturesScreen.routeName: (ctx) => GesturesScreen(),
          SafetyScreen.routeName: (ctx) => SafetyScreen(),
          ActivityScreen.routeName: (ctx) => ActivityScreen(),
          GiveASuggestionScreen.routeName: (ctx) => GiveASuggestionScreen(),
          ReportABugScreen.routeName: (ctx) => ReportABugScreen(),
          AcknowledgementsScreen.routeName: (ctx) => AcknowledgementsScreen(),

          
        });
  }
}
