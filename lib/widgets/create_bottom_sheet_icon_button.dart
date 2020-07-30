import 'dart:ui';
import 'package:flutter/material.dart';
 

class CreateBottomSheetIconButton extends StatelessWidget {


  Column createPostButton({Widget icon, String text, Function function}) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: <Widget>[
              IconButton(icon: icon, onPressed: function),
            ],
          ),
        ),
        SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w500),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.more_vert,size: 18,),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              builder: (context) => ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    child: new BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10.0,
                        sigmaY: 10.0,
                      ),
                      child: new Container(
                        width: MediaQuery.of(context).size.width,
                        height: 250.0,
                        decoration: new BoxDecoration(
                            color: Colors.grey.shade200.withOpacity(0.5)),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Create List',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: () {},
                                  child: Text(
                                    'With Polling',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Colors.grey[200],
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20,),
                                ),SizedBox(width: 25,),
                                 FlatButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Without Polling',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Colors.grey[200],
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20,),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Create Post',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ));
        });
  }
}
