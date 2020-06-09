import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../widgets/email_form.dart';
import '../utils/http.dart';
import '../config/palette.dart';

class EmailBox extends StatelessWidget {
  final Map data;
  final Function callback;

  EmailBox(this.data, this.callback);

  @override
  Widget build(BuildContext context) {
    var time = timeago.format(DateTime.parse(data["creation"]));

    var document = parse(data["content"]);
    String parsedContent = parse(document.body.text).documentElement.text;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ViewEmail(
                      time: time,
                      refDoctype: data["reference_doctype"],
                      refName: data["reference_name"],
                      title: data["subject"],
                      author: data["sender_full_name"],
                      content: data["content"],
                      callback: callback);
                },
              ),
            );
          },
          subtitle:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
              child: Text(
                data["subject"],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black),
              ),
            ),
            Text(
              parsedContent,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ]),
          title: Row(
            children: [
              Text('${data["sender_full_name"]}'),
              Spacer(),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ViewEmail extends StatelessWidget {
  final String title;
  final String time;
  final String author;
  final String content;
  final String refDoctype;
  final String refName;
  final Function callback;

  ViewEmail({
    @required this.callback,
    @required this.title,
    @required this.time,
    @required this.author,
    @required this.content,
    @required this.refDoctype,
    @required this.refName,
  });

  void _choiceAction(String choice, context) {
    if (choice == 'Reply') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return EmailForm(
              doctype: refDoctype,
              doc: refName,
              callback: callback,
              subject: title,
              isReply: true,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (val) => _choiceAction(val, buildContext),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Reply'),
                  value: "Reply",
                ),
              ];
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Card(
            elevation: 4,
            child: Container(
              color: Palette.bgColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(author[0].toUpperCase()),
                    ),
                    title: Text(author),
                    subtitle: Text(time),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: Html(data: content),
          )
        ],
      ),
    );
  }
}
