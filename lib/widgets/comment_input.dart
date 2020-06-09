import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/widgets/rich_text_editor.dart';
import 'package:zefyr/zefyr.dart';

import '../utils/http.dart';

class CommentInput extends StatelessWidget {
  final String doctype;
  final String docName;
  final String authorEmail;
  final Function callback;
  final String comment;
  final String commentName;

  CommentInput({
    this.doctype,
    this.commentName,
    this.docName,
    this.authorEmail,
    @required this.callback,
    this.comment,
  });

  void _postComment(refDocType, refName, content, email) async {
    var c = convertToHtml(content);

    var queryParams = {
      'reference_doctype': refDocType,
      'reference_name': refName,
      'content': c,
      'comment_email': email,
      'comment_by': email
    };

    final response2 = await dio.post(
        '/method/frappe.desk.form.utils.add_comment',
        data: queryParams,
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response2.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // return DioResponse.fromJson(response2.data);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }

    callback();
  }

  void _updateComment(name, content) async {
    var c = convertToHtml(content);

    var queryParams = {
      'content': c,
      'name': name,
    };

    final response2 = await dio.post(
        '/method/frappe.desk.form.utils.update_comment',
        data: queryParams,
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response2.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // return DioResponse.fromJson(response2.data);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }

    callback();
  }

  @override
  Widget build(BuildContext context) {
    final ZefyrController _controller = ZefyrController(loadDocument(comment));
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              // if(_input.text.isEmpty) {
              //   return;
              // }
              if (comment != null) {
                await _updateComment(
                  commentName,
                  _controller.document,
                );
              } else {
                await _postComment(
                  doctype,
                  docName,
                  _controller.document,
                  authorEmail,
                );
              }
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: EditorPage(controller: _controller),
    );
  }
}
