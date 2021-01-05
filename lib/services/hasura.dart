import 'package:hasura_connect/hasura_connect.dart';



class Hasura{
 static const String url = 'https://hasura-test-project.hasura.app/v1/graphql';
static HasuraConnect hasuraConnect = HasuraConnect(url,);
static insertUser(String name, String id)async{
  String _doc = 'mutation {insert_users(objects:[{id: "$id", name:"$name"}]) {affected_rows  }}'; 
  await hasuraConnect.mutation(_doc,
  variables:{
    "content-type":"application/json",
    "x-hasura-admin-secret":"qwertyuiop",
    "Hasura-Client-Name":"user"
    
  }  );
}

}