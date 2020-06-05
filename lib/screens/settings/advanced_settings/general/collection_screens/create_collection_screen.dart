import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateCollectionScreen extends StatelessWidget {
  static const routeName = 'create-collection';
  TextEditingController collectionNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> collectionNames =
        ModalRoute.of(context).settings.arguments as Map<String, List<String>>;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,centerTitle: true,
          title: Text(
            'Create Collection',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.clear,color: Colors.grey,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                if (!collectionNames['collectionNames']
                    .contains(collectionNameController.text) &&collectionNameController.text.isEmpty != null) {
                  collectionNames['collectionNames']
                      .add(collectionNameController.text);
                      Navigator.pop(context);
                
                }
              },
              child: Text(
                'Done',
                style: TextStyle(
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
          children: <Widget>[
            TextField(
              controller: collectionNameController,
              decoration: InputDecoration(
                hintText: 'Name',
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                border: OutlineInputBorder(),
                fillColor: Colors.grey[200],
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              keyboardType: TextInputType.text,
              maxLines: 1,
              onSubmitted: null,
            ),
          ],
        ),
      ),
    );
  }
}
