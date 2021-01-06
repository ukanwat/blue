import 'package:blue/main.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class Boxes{
  static Box voteBox;
 static  Box saveBox;
 static  Box followingBox;
static Box draftBox;
static Box preferenceBox;
static Box currentUserBox;
static Future openBoxes() async {
    if(currentUser == null)
  return;
  try{
 var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  voteBox =  await Hive.openBox('votes');
  saveBox =  await Hive.openBox('saves');
  followingBox =  await Hive.openBox('followings');
  draftBox =  await Hive.openBox('drafts');
  preferenceBox = await Hive.openBox('preferences');
    currentUserBox = await Hive.openBox('currentUser');
  boxesOpened = true;
    loadVotes();
  }catch(e){
    
  }
 

}
}