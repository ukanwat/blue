import 'package:flutter/material.dart';

class PostSettingsScreen extends StatefulWidget {
  static const routeName = 'post-settings';

  @override
  _PostSettingsScreenState createState() => _PostSettingsScreenState();
}

class _PostSettingsScreenState extends State<PostSettingsScreen> {
  String contentCategoryValue;
   bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    final postData = ModalRoute.of(context).settings.arguments as Map<String,dynamic>;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            'Post Settings',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon:Icon(Icons.arrow_back_ios), onPressed: (){
            Navigator.pop(context);
            },
            color: Colors.grey,
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: postData['post-function'],
              child: Text(
                'Post',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor),
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(width: 10),
              Text(
                'Select Community',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              )
            ],
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Content Category',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: DropdownButton<String>(
                      value: contentCategoryValue,
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 42,
                      underline: SizedBox(),
                      onChanged: (String newValue) {
                        setState(() {
                          contentCategoryValue = newValue;
                        });
                      },
                      elevation: 1,
                      items: <String>[
                        'General',
                        'Adult Content',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList()),
                )
              ],
            ),
          ),Divider(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Schedule Post',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                  ), Switch(
          value: isSwitched,
          onChanged: (value){
            setState(() {
              isSwitched=value;
              print(isSwitched);
            });
          },
          activeTrackColor: Colors.blueAccent,
          activeColor: Colors.grey[100],
        ),
                ]),
          )
        ],
      ),
    );
  }
}
