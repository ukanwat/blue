import 'package:flutter/material.dart';
class SetNameScreen extends StatefulWidget {
  static const routeName = 'set-name';
  @override
  _SetNameScreenState createState() => _SetNameScreenState();
}

class _SetNameScreenState extends State<SetNameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).accentColor,
        body: Container(width:double.infinity,
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Image.asset('assets/images/stark-bnb-icon-wa.png'),
            SizedBox(height: 20),
            Text('Stark',style: TextStyle(color: Colors.white,fontSize: 50,fontFamily: 'Techna Sans Regular'),),
            
            FittedBox(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
          elevation: 10,margin: EdgeInsets.all(
            30
          ),
          
          child:  Form(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 10,
              right:10,
              top: 20,
            ),
            width: MediaQuery.of(context).size.width - 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
               
                SizedBox(height: 20),
               
                SizedBox(height: 10),
              ],
            ),
          ),
          Container(
            
            width: 100,padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
 backgroundColor: Theme.of(context).accentColor  , shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))), ),
                child: Text('Done',
              
              style: TextStyle(color: Colors.white,fontSize: 20)),onPressed: (){
                Navigator.pop(context);
                   Navigator.pop(context);
              },),
              ],
            ),
          ),
        ],
      ),
    )
      ),
    )
          ],),
        )
      );
  }
}



class GradientBox extends StatelessWidget {
  GradientBox({
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      child: SizedBox.expand(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: begin,
          end: end,
          stops: [0, 1],
        ),
      ),
    );
  }
}
