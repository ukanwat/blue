import 'package:cloud_firestore/cloud_firestore.dart';

class Topic {
  final String id;
  final String name;
  final String imageUrl;
  final Map<String, String> info;

  Topic({
    this.id,
    this.name,
    this.imageUrl,
    this.info,
  });

  factory Topic.fromDocument(DocumentSnapshot doc) {
    return Topic(
      id: doc['id'],
      name: doc['name'],
      imageUrl: doc['imageUrl'],
      info: doc['info'],
    );
  }
}
