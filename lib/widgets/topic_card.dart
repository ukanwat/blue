// import 'package:blue/screens/category_posts_screen.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';

// class TopicCard extends StatelessWidget {
//   final String topicName;
//   final String topicImageUrl;
//   final String topicId;
//   final Map<String, dynamic> topicInfo;
//   final double sideLength;
//   TopicCard(this.topicName, this.topicImageUrl, this.topicId, this.topicInfo,
//       this.sideLength);
//   showTopicPostsScreen(BuildContext context) {
//     Navigator.of(context).pushNamed(TopicPostsScreen.routeName, arguments: {
//       'name': topicName,
//       'imageUrl': topicImageUrl,
//       'id': topicId,
//       'info': topicInfo
//     });
//   }
  
//   @override
//   Widget build(BuildContext context) {
    
//     return Container(
//       child: GestureDetector(
//         onTap: () {
//           showTopicPostsScreen(context);
//         },
//         child: Card(

//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           elevation: 1,
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
//             child: Text(topicName,style: TextStyle(fontSize: 16),),)
//         ),
//       ),
//     );
//   }
// }
