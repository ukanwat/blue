// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

// Project imports:
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/url_bottom_sheet.dart';

class CommunityGuidelinesScreen extends StatefulWidget {
  static const routeName = 'community-guidelines';

  @override
  _CommunityGuidelinesScreenState createState() =>
      _CommunityGuidelinesScreenState();
}

class _CommunityGuidelinesScreenState extends State<CommunityGuidelinesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Community Guidelines'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Section 1: Illegal Content',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text("""

(A) Underage Sexual Content
Posting underage sexual content will result in an immediate ban. To be on the safe side, this also applies to content that is "ambiguous". Don't do it.

(B) Doxxing / Physical Threats
You may not post any content or actions that threaten physical harm or otherwise incite violence.

(C) Copyrighted Content
We have neither the resources nor the inclination to determine if the contents of your post is properly licensed. We will only take proactive action to remove content that is obviously infringing on someone's copyright. Other than that, we will respond on a case-by-case basic to any complaints we receive from copyright holders under DMCA.
"""),
              Text(
                'Section 2: Explicit Content',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text("""

(A) Violence / Gore
Please don't post overly graphic/violent/disturbing images or video.

(B) NSFW Content
Please don't post pornographic material. We don't have the resources to moderate it at the current time.
"""),
              Text(
                'Section 3: Spam',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text("""

(A) Phishing / Deception
Impersonating someone, or otherwise attempting to materially defraud other users will result in a ban.

(B) Disruptive Content
Repeatedly posting the same content, posting something incomprehensible (like just mashing your keyboard), deliberately miscategorizing posts, or repeatedly posting advertisements or other low-effort content without any context or explanation is not allowed. The general principle is that "bad faith" posts will be removed so they don't distract from valuable content.
"""),
            ],
          ),
        ),
      ),
    );
  }
}
