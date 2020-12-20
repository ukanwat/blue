import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
Widget emptyState(BuildContext context,String title,String svgName,{String subtitle,} ){
 return Container(width: double.infinity,height: MediaQuery.of(context).size.height,
      child: Center(
      child: Column(mainAxisSize: MainAxisSize.min,
children: [
  Container(color: Colors.transparent,height: MediaQuery.of(context).size.width*0.4,
  padding: EdgeInsets.all(15),
    child: SvgPicture.asset(
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
