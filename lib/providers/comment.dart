import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



class CommentNotifier extends ChangeNotifier {
  Map<String,String> _commentState;

  Map<String,String> get commentState {return _commentState;}
  
   FocusNode focusNode = new FocusNode();

  CommentNotifier() {
    _commentState = {'type': 'comment'};
      notifyListeners();
  }

  changeCommentType(var value ,{bool focus}) {
    _commentState = value;
    notifyListeners();
    if(focus == true ){
  focusNode.requestFocus();
  SystemChannels.textInput.invokeMethod('TextInput.show');
    }
  }


}