// Flutter imports:
import 'package:blue/services/hasura.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import '../../../home.dart';

class CreateCollectionScreen extends StatefulWidget {
  static const routeName = 'create-collection';

  @override
  _CreateCollectionScreenState createState() => _CreateCollectionScreenState();
}

class _CreateCollectionScreenState extends State<CreateCollectionScreen> {
 final TextEditingController collectionNameController = TextEditingController();
 
    final formKey = GlobalKey<FormState>();
@override
  void initState() {
    super.initState();
  }

   saveCollection()async {
     formKey.currentState.validate();
     if(collectionNameController.text.length > 0 && formKey.currentState.validate()){
   
       formKey.currentState.save();
      await  Hasura.insertCollection(collectionNameController.text);
      Navigator.pop(context,true);
     }else{
        Navigator.pop(context,false);
     }
     
     
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 1,centerTitle: true,
          title: Text(
            'Create Collection',
            style: TextStyle(),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.clear,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                 saveCollection();
                
              },
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 20,
                color:  collectionNameController.text.isEmpty == null?
                  Colors.grey: Colors.blue,
                ),
              ),
            )
          ],
        ),
      ),
      body: Container(padding: EdgeInsets.only(
        top: 15,
        left: 14,
        right: 14
      ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(   key: formKey,
              child:
           TextFormField(
          
             onSaved: (value){

             },
                           validator: (value){
              
               if(value.length == 0 ){
                return 'Collection name must have atleast 1 character';
              }
              return null;
              },
                      controller: collectionNameController,
                      decoration: InputDecoration(
                        hintText: 'Name',
                        fillColor: Theme.of(context).cardColor,
                        hintStyle: TextStyle(
                            color: Theme.of(context)
                                .iconTheme
                                .color
                                .withOpacity(0.8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).cardColor,
                            width: 1,
                          ),
                        ),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Theme.of(context).cardColor, width: 1),
                        ),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      maxLines: 1,
                    
                    ),),
            SizedBox(height:100),
          ],
        ),
      ),
    );
  }
}
