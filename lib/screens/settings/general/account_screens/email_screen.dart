import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmailScreen extends StatefulWidget {
  static const routeName = 'email';

  @override
  _EmailScreenState createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
 TextEditingController newEmailController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,centerTitle: true,
            title: Text(
              'Change Email',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            automaticallyImplyLeading: false,
            leading: CupertinoNavigationBarBackButton(
              color: Colors.grey,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: <Widget>[FlatButton(onPressed: (){
            
              }, child: Text(
                'Done',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ))
              
            ],
          )),
      body: Container(
        height: MediaQuery.of(context).size.height -
            100 -
            MediaQuery.of(context).padding.top,
        child: Center(
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: newEmailController,
                    decoration: InputDecoration(
                      hintText: 'Change Email',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      border: OutlineInputBorder(),fillColor: Colors.grey[200],
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
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    onSubmitted: null,
                  ),
                ),
               
              ],
            ),
          ),
        ),
      ),
    );
  }
}
