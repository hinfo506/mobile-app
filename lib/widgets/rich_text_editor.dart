import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

class EditorPage extends StatefulWidget {
  final String data;
  final ZefyrController controller;

  EditorPage({
    this.controller,
    this.data,
  });

  @override
  EditorPageState createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {

  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return ZefyrScaffold(
      child: ZefyrField(
        height: double.infinity,
        controller: widget.controller,
        focusNode: _focusNode,
        autofocus: false,
        physics: ClampingScrollPhysics(),
      ),
    );
  }
}
