import 'package:flutter/material.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';

class EditorField extends StatefulWidget {
    final FocusNode focusNode;
  final ZefyrController controller;

  EditorField(
    { this.focusNode,
    this.controller
    }
  );
  @override
  _EditorFieldState createState() => _EditorFieldState(controller: this.controller,focusNode:this.focusNode);
}

class _EditorFieldState extends State<EditorField> {
   FocusNode focusNode;
  ZefyrController controller;
  _EditorFieldState({
    this.focusNode,
    this.controller

  });

  @override
  void initState() {
    super.initState();
    // Here we must load the document and pass it to Zefyr controller.
    final document = _loadDocument();
        controller = ZefyrController(document);
    focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return ZefyrField(
      height: 200.0,
      decoration: InputDecoration(labelText: 'Description'),
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      physics: ClampingScrollPhysics(),
      
    );
  }

  /// Loads the document to be edited in Zefyr.
  NotusDocument _loadDocument() {
    // For simplicity we hardcode a simple document with one line of text
    // saying "Zefyr Quick Start".
    // (Note that delta must always end with newline.)
    final Delta delta = Delta()..insert("Text...\n");
    return NotusDocument.fromDelta(delta);
  }
}