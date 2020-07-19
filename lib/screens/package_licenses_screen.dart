import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PackageLicensesScreen extends StatefulWidget {
  static const routeName = 'package-licenses';

  @override
  _PackageLicensesScreenState createState() => _PackageLicensesScreenState();
}

class _PackageLicensesScreenState extends State<PackageLicensesScreen> {
  String title = '';
  List licenses = [];
  List<Widget> licenseWidgets = [];
  bool loading = true;
  @override
  void didChangeDependencies() {
   Map arguments = ModalRoute.of(context).settings.arguments as Map;
   title = arguments['name'];
   licenses = arguments['licenses'];
     setState((){
          for(int i =0; i<licenses.length ;i++){
             licenseWidgets.add( Container(
          margin: EdgeInsets.symmetric(vertical: 24.0),
          height: 0.7,width: MediaQuery.of(context).size.width - 100,
          color: Colors.grey[300],
        ),
      );
               for (final LicenseParagraph paragraph in licenses[i]) {
        if (paragraph.indent == LicenseParagraph.centeredIndent) {
          licenseWidgets.add(Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              paragraph.text,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ));
        } else {
          print(paragraph.text);
          assert(paragraph.indent >= 0);
          licenseWidgets.add(Padding(
            padding: EdgeInsetsDirectional.only(top: 8.0, start: 16.0 * paragraph.indent),
            child: Text(paragraph.text,
            style: TextStyle(),),
          ));
        }
      }
          }
                 licenseWidgets.add( Container(
          margin: EdgeInsets.symmetric(vertical: 24.0),
          height: 0.5,width: MediaQuery.of(context).size.width - 100,
          color: Colors.grey[300],
        ));
    
       loading = false;
      });
  
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0,
        title: Text('',
        ),
        automaticallyImplyLeading: false,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.blue,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),),
      body: !loading?  ListView(
        
      padding: EdgeInsets.symmetric(horizontal: 10),
        children: <Widget>[  
         Container(
           child: Text(title,
           style: TextStyle(
             fontSize: 22,
             fontWeight: FontWeight.w600
           ),)
          ),
        
        Padding(
          padding: const EdgeInsets.symmetric( vertical: 10),
          child: Container(
           child: Text(licenses.length> 1?'${licenses.length} Licenses':'License',
           style: TextStyle(
             fontSize: 14,
             fontWeight: FontWeight.w500
           ),)
          ),
        ),
        ...licenseWidgets
        ],
      ): circularProgress(),
      
    );
  }
}