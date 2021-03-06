import 'package:flutter/material.dart';

import '../main.dart';
import '../config/palette.dart';
import '../widgets/card_list_tile.dart';
import '../utils/backend_service.dart';
import '../utils/helpers.dart';
import './doctype_view.dart';

class ModuleView extends StatelessWidget {
  static const _supportedModules = ['Support', 'CRM'];
  final user = localStorage.getString('user');
  static const popupOptions = const ["Logout"];

  void _choiceAction(String choice, context) {
    if (choice == "Logout") {
      logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var backendService = BackendService(context);
    return FutureBuilder(
      future: backendService.getDeskSideBarItems(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var modules = snapshot.data["message"]["Modules"];
          var modulesWidget = modules.where((m) {
            return _supportedModules.contains(m["name"]);
          }).map<Widget>((m) {
            return Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 8.0),
              child: CardListTile(
                title: Text(m["label"]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return DoctypeView(m["name"]);
                      },
                    ),
                  );
                },
              ),
            );
          }).toList();
          return Scaffold(
            backgroundColor: Palette.bgColor,
            appBar: AppBar(
              title: Text('Modules'),
              elevation: 0,
              leading: PopupMenuButton<String>(
                onSelected: (choice) => _choiceAction(choice, context),
                icon: CircleAvatar(
                  child: Text(
                    user[0].toUpperCase(),
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Palette.bgColor,
                ),
                itemBuilder: (BuildContext context) {
                  return popupOptions.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ),
            body: ListView(
              children: modulesWidget,
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
