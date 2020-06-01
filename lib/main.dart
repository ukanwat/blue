import 'package:blue/providers/post_interactions.dart';
import 'package:blue/screens/all_topics_screen.dart';
import 'package:blue/screens/select_topic_screen.dart';
import 'package:blue/screens/settings/about/acknowledgements_screen.dart';
import 'package:blue/screens/settings/advanced_settings/autoplay_screen.dart';
import 'package:blue/screens/settings/advanced_settings/content_cache_screen.dart';
import 'package:blue/screens/settings/advanced_settings/gestures_screen.dart';
import 'package:blue/screens/settings/feedback/give_a_suggestion_screen.dart';
import 'package:blue/screens/settings/feedback/report_a_bug_screen.dart';
import 'package:blue/screens/settings/general/account_screen.dart';
import 'package:blue/screens/settings/general/account_screens/deactivate_account_screen.dart';
import 'package:blue/screens/settings/general/account_screens/logins.dart';
import 'package:blue/screens/settings/general/account_screens/password_screen.dart';
import 'package:blue/screens/settings/general/collection_screens/create_collection_screen.dart';
import 'package:blue/screens/settings/general/collections_screen.dart';
import 'package:blue/screens/settings/general/drafts_screen.dart';
import 'package:blue/screens/settings/general/personalize_screen.dart';
import 'package:blue/screens/settings/notification/email_notifications_screen.dart';
import 'package:blue/screens/settings/notification/push_notifications_screen.dart';
import 'package:blue/screens/settings/privacy/activity_screen.dart';
import 'package:blue/screens/settings/privacy/activity_screens/account_privacy_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screens/blocked_accounts_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screens/muted_accounts_screen.dart';
import 'package:blue/screens/topic_posts_screen.dart';
import 'package:flutter/material.dart';
import 'package:blue/screens/chat_info_screen.dart';
import 'package:blue/screens/gifs_screen.dart';

import 'package:blue/screens/chat_messages_screen.dart';
import './screens/search_screen.dart';
import './screens/edit_profile_screen.dart';
import './screens/home.dart';
import './screens/post_screen.dart';
import './screens/comments_screen.dart';
import './screens/settings_screen.dart';
import 'screens/settings/general/account_screens/email_screen.dart';

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
          SelectTopicScreen.routeName: (ctx) => SelectTopicScreen(),
          TopicPostsScreen.routeName: (ctx) => TopicPostsScreen(),
          AllTopicsScreen.routeName: (ctx) => AllTopicsScreen(),
          SettingsScreen.routeName: (ctx) => SettingsScreen(),
          ChatInfoScreen.routeName: (ctx) => ChatInfoScreen(),
          GIFsScreen.routeName: (ctx) => GIFsScreen(),

          AccountScreen.routeName: (ctx) => AccountScreen(),
          PersonalizeScreen.routeName: (ctx) => PersonalizeScreen(),
          CollectionsScreen.routeName: (ctx) => CollectionsScreen(),
          DraftsScreen.routeName: (ctx) => DraftsScreen(),
          PushNotificationsScreen.routeName: (ctx) => PushNotificationsScreen(),
          EmailNotificationsScreen.routeName: (ctx) => EmailNotificationsScreen(),
          AutoplayScreen.routeName: (ctx) => AutoplayScreen(),
          ContentCacheScreen.routeName: (ctx) => ContentCacheScreen(),
          GesturesScreen.routeName: (ctx) => GesturesScreen(),
          SafetyScreen.routeName: (ctx) => SafetyScreen(),
          ActivityScreen.routeName: (ctx) => ActivityScreen(),
          GiveASuggestionScreen.routeName: (ctx) => GiveASuggestionScreen(),
          ReportABugScreen.routeName: (ctx) => ReportABugScreen(),
          AcknowledgementsScreen.routeName: (ctx) => AcknowledgementsScreen(),

          EmailScreen.routeName: (ctx) => EmailScreen(),
          PasswordScreen.routeName: (ctx) => PasswordScreen(),
        DeactivateAccountScreen.routeName: (ctx) => DeactivateAccountScreen(),
          LoginsScreen.routeName: (ctx) => LoginsScreen(),
          CreateCollectionScreen.routeName: (ctx) => CreateCollectionScreen(),

          BlockedAccountsScreen.routeName: (ctx) => BlockedAccountsScreen(),
          MutedAccountsScreen.routeName: (ctx) => MutedAccountsScreen(),
          AccountPrivacyScreen.routeName: (ctx)=> AccountPrivacyScreen(),

          
        });
  }
}
