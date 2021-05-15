import 'package:blue/main.dart';
import 'package:blue/models/hive_data_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class Boxes {
  static Box saveBox;
  static Box followingBox;
  static Box draftBox;
  static Box preferenceBox;
  static Box currentUserBox;
  static Box notInterestedBox;

  Future<Box> userBox() async {
    var box = await Hive.openBox<HiveUser>('user');
    return box;
  }

  static Future openCurrentUserBox() async {
    currentUserBox = await Hive.openBox('currentUser');
  }

  static Future clearBoxes() async {
    if (saveBox != null) await saveBox.deleteFromDisk();
    if (followingBox != null) await followingBox.deleteFromDisk();
    if (notInterestedBox != null) await notInterestedBox.deleteFromDisk();
    if (draftBox != null) await draftBox.deleteFromDisk();
    if (preferenceBox != null) await preferenceBox.deleteFromDisk();
    if (currentUserBox != null) await currentUserBox.deleteFromDisk();
  }

  static Future openBoxes() async {
    saveBox = await Hive.openBox('saves');
    followingBox = await Hive.openBox('followings');
    draftBox = await Hive.openBox('drafts');
    preferenceBox = await Hive.openBox('preferences');
    notInterestedBox = await Hive.openBox('comment_votes');
    boxesOpened = true;
  }
}
