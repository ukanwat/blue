// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/providers/provider_widget.dart';

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
            backgroundColor: Theme.of(context).canvasColor,
            elevation: 0,centerTitle: true,
            title: Text(
              'Change Email',
              
            ),
            automaticallyImplyLeading: false,
            leading: CupertinoNavigationBarBackButton(
              color: Colors.blue,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: <Widget>[FlatButton(onPressed: (){
             var auth =  Provider.of(context).auth;
             auth.changeEmail(newEmailController.text, 'password');              //TODO and errors
              }, child: Text(
                'Done',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18
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
                  child: TextFormField(
                      validator: (value) {
                        if(value.isEmpty)
                        return "Email can't be empty";
                        return null;
                      },
                      controller: newEmailController,
                      decoration: InputDecoration(
                      
                     
                        hintText: 'New Email',
                        fillColor: Theme.of(context).cardColor,
                        hintStyle: TextStyle(
                            color: Theme.of(context)
                                .iconTheme
                                .color
                                .withOpacity(0.8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 5),
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
