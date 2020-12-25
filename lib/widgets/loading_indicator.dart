import 'package:flutter/material.dart';
import './progress.dart';
showLoadingIndicator(BuildContext context){
  
                    showDialog(
                        barrierDismissible: true,
                        // useRootNavigator: false,
                        context: context,
                        builder: (BuildContext context) => WillPopScope(
                              onWillPop: () async {
                                return true;
                              },
                              child: Dialog(
                                
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 1.0,
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 25, horizontal: 15),
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10.0,
                                        offset: const Offset(0.0, 10.0),
                                      ),
                                    ],
                                  ),
                                  child: circularProgress(),
                                ),

                              ),

                            ));
}