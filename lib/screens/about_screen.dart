// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:blue/models/user.dart';
import 'package:blue/widgets/header.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = 'about';
    String compactString(int value) {
    const units = <int, String>{
      1000000000: 'B',
      1000000: 'M',
      1000: 'K',
    };
    return units.entries
        .map((e) => '${value ~/ e.key}${e.value}')
        .firstWhere((e) => !e.startsWith('0'), orElse: () => '$value');
  }
   Expanded buildCountColumn(String label, int count,BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: Text(
                compactString(count), // TODO improve formatting
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(label,style: TextStyle(fontWeight: FontWeight.w500,color: Theme.of(context).iconTheme.color.withOpacity(0.6)),),
            ),
          ],
        ),
      ),
    );
  }
  
  launchWebsite(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  Widget build(BuildContext context) {
    User user = ModalRoute.of(context).settings.arguments as User;
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
      appBar: header(context,leadingButton: CupertinoNavigationBarBackButton(color: Colors.blue,),centerTitle: true,title: Text('About')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[Container(
  margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/2 - 72,top: 40,right:  MediaQuery.of(context).size.width/2 - 72),
        child: CircleAvatar(
          
          backgroundColor: Theme.of(context).backgroundColor,maxRadius: 72,minRadius: 72,backgroundImage: CachedNetworkImageProvider(user.photoUrl),)),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text(user.displayName,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),)),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(elevation: 1,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),color: Theme.of(context).canvasColor,
                    child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      buildCountColumn(
                                         'Following', 24243335,context),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          color: Colors.grey,
                                        ),
                                        height: 40,
                                        width: 1,
                                      ),
                                      buildCountColumn(
                                         'Followers',
                                          123,context),
                                    ],
                                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15,top: 15,bottom: 5),
          child: Text('Website',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500)),
        ),
           Padding(
             padding: const EdgeInsets.only(left: 15,),
             child: Linkify(
                            text: user.website,
                            linkStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.blue,
                              decoration: TextDecoration.none,
                            ),
                            onOpen: (link) {
                              launchWebsite(user.website);
                            },
                            overflow: TextOverflow.ellipsis,
                          ),
           ),
         Padding(
           padding: const EdgeInsets.only(top: 15,left: 15,bottom: 5),
           child: Text('Bio',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500)),
         ),
 Padding(
           padding: const EdgeInsets.only(left: 15),
           child: Text(user.bio,style: TextStyle(fontSize: 16,)),
         ),
         Padding(
           padding: const EdgeInsets.only(top: 15,left: 15,bottom: 5),
           child: Text('Joined',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500)),
         ),
         Padding(
           padding: const EdgeInsets.only(left: 15),
           child: Text('--',style: TextStyle(fontSize: 16,)),
         ),
        
        ],),
    );
  }
}
