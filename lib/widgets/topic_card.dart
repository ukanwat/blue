import 'package:blue/screens/topic_posts_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TopicCard extends StatelessWidget {
  final String topicName;
  final String topicImageUrl;
  final String topicId;
  final Map<String, dynamic> topicInfo;
  final double sideLength;
  TopicCard(this.topicName, this.topicImageUrl, this.topicId, this.topicInfo,
      this.sideLength);
  showTopicPostsScreen(BuildContext context) {
    Navigator.of(context).pushNamed(TopicPostsScreen.routeName, arguments: {
      'name': topicName,
      'imageUrl': topicImageUrl,
      'id': topicId,
      'info': topicInfo
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: sideLength,
      width: sideLength,
      child: GestureDetector(
        onTap: () {
          showTopicPostsScreen(context);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: CachedNetworkImageProvider(topicImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: sideLength,
                width: sideLength,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black45],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [
                        0.3,
                        0.85,
                      ]),
                ),
                alignment: Alignment(0, 0.9),
                child: Text(
                  topicName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
