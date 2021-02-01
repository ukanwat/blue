// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';


class User {
final dynamic id;
final String username;
final String email;
final String photoUrl;
final String name;
final String about;
final String website;
final String headerUrl;
final String avatarUrl;
User({
  this.id,
  this.username,
  this.email,
  this.photoUrl,
  this.name,
  this.about,
  this.website,
  this.headerUrl,
  this.avatarUrl
});

factory User.fromDocument(Map doc){
  return User(
    id: doc['id'],
    email: doc['email'],
    username: doc['username'],
    photoUrl: doc['photo_url'],
    name: doc['name'],
    about: doc['about'],
    website: doc['website'],
    headerUrl: doc['header_url'],
    avatarUrl: doc['avatar_url'],
  );
}

}

