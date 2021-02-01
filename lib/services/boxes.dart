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
static var dir;
static Future openCurrentUserBox() async {
   
  try{
        if(dir == null){
 dir = await getApplicationDocumentsDirectory();
    }
 if(!Hive.isBoxOpen('votes')){
 Hive.init(dir.path);
 }
    currentUserBox = await Hive.openBox('currentUser');
  }catch(e){
    
  }
 

}
static Future clearBoxes()async{
  if(voteBox!= null)
 await  voteBox.deleteFromDisk();
  if(saveBox!= null)
  await saveBox.deleteFromDisk();
   if(followingBox!= null)
  await followingBox.deleteFromDisk();
   if(draftBox!= null)
  await draftBox.deleteFromDisk(); 
   if(preferenceBox!= null)
  await preferenceBox.deleteFromDisk();
   if(currentUserBox!= null)
  await    currentUserBox.deleteFromDisk();
}
static Future openBoxes() async {
   
  try{
    if(dir == null){
 dir = await getApplicationDocumentsDirectory();
    }
 if(!Hive.isBoxOpen('currentUser')){
 Hive.init(dir.path);
 }
 
  voteBox =  await Hive.openBox('votes');
  saveBox =  await Hive.openBox('saves');
  followingBox =  await Hive.openBox('followings');
  draftBox =  await Hive.openBox('drafts');
  preferenceBox = await Hive.openBox('preferences');
  boxesOpened = true;
  }catch(e){
    
  }
 

}
}