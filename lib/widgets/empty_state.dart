// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget emptyState(BuildContext context,String title,String svgName,{String subtitle,} ){
 return Container(width: double.infinity,height: MediaQuery.of(context).size.height,
      child: Center(
      child: Column(mainAxisSize: MainAxisSize.min,
children: [
  Container(color: Colors.transparent,height: MediaQuery.of(context).size.width*0.4,
  padding: EdgeInsets.all(15),
    child: 
    svgName == 'none'?
    Container(
      height: MediaQuery.of(context).size.width*0.4,
      width:  MediaQuery.of(context).size.width*0.4,
      child: Center(child:
       Stack(
                  children: <Widget>[
                    Positioned(
                      left: 1.2,
                      top: 1.8,
                      child: Icon(Icons.inbox_rounded, color: Colors.black38,size: 55,),
                    ),
                    Icon(Icons.inbox_rounded, color: Theme.of(context).iconTheme.color.withOpacity(0.6),size: 55,),
                  ],
                ),
       ),
      decoration: BoxDecoration(shape: BoxShape.circle,color: Theme.of(context).cardColor,),
    ):
    SvgPicture.asset(
  'assets/images/$svgName.svg',

  allowDrawingOutsideViewBox: true,
),
  ), Padding(
    padding: EdgeInsets.symmetric(horizontal: 60),
    child: Text(title,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 19),)),
  if(subtitle != null)  Padding(
      padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 40),
      child: Text(subtitle,textAlign: TextAlign.center,style:TextStyle(fontWeight: FontWeight.w400,fontSize: 15,color: Theme.of(context).iconTheme.color.withOpacity(0.8))),
    )
],

      ),
        ));
}
