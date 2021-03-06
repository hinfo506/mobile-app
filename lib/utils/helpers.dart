import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/utils/backend_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/palette.dart';
import '../form/controls/link_field.dart';
import '../form/controls/multi_select.dart';
import '../utils/enums.dart';
import '../main.dart';
import '../app.dart';
import './http.dart';
import '../widgets/custom_expansion_tile.dart';

logout(context) async {
  var cookieJar = await getCookiePath();

  cookieJar.delete(uri);

  localStorage.setBool('isLoggedIn', false);

  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => FrappeApp(),
      ),
      (Route<dynamic> route) => false);
}

Future processData(
  String doctype,
  ViewType viewType,
  context,
) async {
  //TODO: check cache

  var meta = await BackendService(context).getDoctype(doctype);

  List metaFields = meta["docs"][0]["fields"];

  metaFields.forEach((field) {
    if (field["fieldtype"] == "Select") {
      field["options"] = field["options"].split('\n');
    }
  });

  return meta;
}

Widget makeControl(Map field,
    [val, bool withLabel = true, bool editMode = true]) {
  Widget value;
  const fieldPadding = const EdgeInsets.only(bottom: 24.0);
  const labelPadding = const EdgeInsets.only(bottom: 6.0);
  List<String Function(dynamic)> validators = [];

  if (field["reqd"] == 1) {
    validators.add(FormBuilderValidators.required());
  }

  Widget _buildDecoratedWidget(Widget fieldWidget, bool withLabel) {
    if (withLabel) {
      return Padding(
        padding: fieldPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: labelPadding,
              child: Text(field["label"], style: Palette.labelStyle),
            ),
            fieldWidget
          ],
        ),
      );
    } else {
      return Padding(
        padding: fieldPadding,
        child: fieldWidget,
      );
    }
  }

  switch (field["fieldtype"]) {
    case "Link":
      {
        value = _buildDecoratedWidget(
            LinkField(
              allowClear: editMode,
              validators: validators,
              attribute: field["fieldname"],
              doctype: field["options"],
              hint: !withLabel ? field["label"] : null,
              refDoctype: field["refDoctype"],
              value: val,
            ),
            withLabel);
      }
      break;

    case "Select":
      {
        value = _buildDecoratedWidget(
            FormBuilderDropdown(
              initialValue: val,
              allowClear: editMode,
              attribute: field["fieldname"],
              hint: !withLabel ? Text(field["label"]) : null,
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
              items: field["options"].map<DropdownMenuItem>((option) {
                return DropdownMenuItem(
                  value: option,
                  child: option != null
                      ? Text(
                          '$option',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        )
                      : Text(''),
                );
              }).toList(),
            ),
            withLabel);
      }
      break;

    case "MultiSelect":
      {
        if (val != null) {
          val = [
            {
              "value": val,
              "description": val,
            }
          ];
        }

        value = _buildDecoratedWidget(
          MultiSelect(
            attribute: field["fieldname"],
            hint: field["label"],
            val: val != null ? val : [],
          ),
          withLabel,
        );
      }
      break;

    case "Small Text":
      {
        value = _buildDecoratedWidget(
          FormBuilderTextField(
            initialValue: val,
            attribute: field["fieldname"],
            decoration: Palette.formFieldDecoration(
              withLabel,
              field["label"],
            ),
            validators: [
              FormBuilderValidators.required(),
            ],
          ),
          withLabel,
        );
      }
      break;

    case "Data":
      {
        value = _buildDecoratedWidget(
            FormBuilderTextField(
              initialValue: val,
              attribute: field["fieldname"],
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
            ),
            withLabel);
      }
      break;

    case "Check":
      {
        value = _buildDecoratedWidget(
            FormBuilderCheckbox(
              leadingInput: true,
              attribute: field["fieldname"],
              label: Text(field["label"]),
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
            ),
            withLabel);
      }
      break;

    case "Text Editor":
      {
        value = _buildDecoratedWidget(
            FormBuilderTextField(
                maxLines: 10,
                initialValue: val,
                attribute: field["fieldname"],
                decoration: Palette.formFieldDecoration(
                  withLabel,
                  field["label"],
                ),
                validators: validators),
            withLabel);
      }
      break;

    case "Datetime":
      {
        value = _buildDecoratedWidget(
            FormBuilderDateTimePicker(
              valueTransformer: (val) {
                return val != null ? val.toIso8601String() : null;
              },
              resetIcon: editMode ? Icon(Icons.close) : null,
              initialTime: null,
              initialValue: parseDate(val),
              attribute: field["fieldname"],
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
            ),
            withLabel);
      }
      break;

    case "Float":
      {
        value = _buildDecoratedWidget(
            FormBuilderTextField(
              keyboardType: TextInputType.number,
              attribute: field["fieldname"],
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
            ),
            withLabel);
      }
      break;

    case "Time":
      {
        value = _buildDecoratedWidget(
            FormBuilderDateTimePicker(
              inputType: InputType.time,
              valueTransformer: (val) {
                return val != null ? val.toIso8601String() : null;
              },
              keyboardType: TextInputType.number,
              attribute: field["fieldname"],
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
            ),
            withLabel);
      }
      break;

    case "Date":
      {
        value = _buildDecoratedWidget(
            FormBuilderDateTimePicker(
              inputType: InputType.date,
              valueTransformer: (val) {
                return val != null ? val.toIso8601String() : null;
              },
              initialValue: parseDate(val),
              keyboardType: TextInputType.number,
              attribute: field["fieldname"],
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
            ),
            withLabel);
      }
      break;
  }
  return value;
}

downloadFile(String fileUrl) async {
  await _checkPermission();

  final absoluteUrl = getAbsoluteUrl(fileUrl);
  var downloadsPath;

  // TODO
  if (Platform.isAndroid) {
    downloadsPath = '/storage/emulated/0/Download/';
  } else if (Platform.isIOS) {
    final Directory downloadsDirectory =
        await getApplicationDocumentsDirectory();
    downloadsPath = downloadsDirectory.path;
  }

  await FlutterDownloader.enqueue(
    headers: {
      HttpHeaders.cookieHeader: await getCookies(),
    },
    url: absoluteUrl,
    savedDir: downloadsPath,
    showNotification:
        true, // show download progress in status bar (for Android)
    openFileFromNotification:
        true, // click on notification to open downloaded file (for Android)
  );
}

Future<bool> _checkPermission() async {
  if (Platform.isAndroid) {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
  } else {
    return true;
  }
  return false;
}

Map<String, Color> setStatusColor(String doctype, String status) {
  var doctypeColor = {
    'Issue': {
      'Open': Colors.red,
      'Closed': Colors.green,
    }
  };

  if (doctypeColor[doctype] != null && doctypeColor[doctype][status] != null) {
    return {
      'bgColor': doctypeColor[doctype][status][50],
      'txtColor': doctypeColor[doctype][status][800]
    };
  } else if (["Pending", "Review", "Medium", "Not Approved"].contains(status)) {
    return {
      'bgColor': Colors.orange[100],
      'txtColor': Colors.orange[800],
    };
  } else if (["Open", "Urgent", "High", "Failed", "Rejected", "Error"]
      .contains(status)) {
    return {
      'bgColor': Colors.red[100],
      'txtColor': Colors.red[800],
    };
  } else if ([
    "Closed",
    "Finished",
    "Converted",
    "Completed",
    "Complete",
    "Confirmed",
    "Approved",
    "Yes",
    "Active",
    "Available",
    "Paid",
    "Success",
  ].contains(status)) {
    return {
      'bgColor': Colors.green[100],
      'txtColor': Colors.green[800],
    };
  } else if (["Submitted"].contains(status)) {
    return {
      'bgColor': Colors.blue[100],
      'txtColor': Colors.blue[800],
    };
  } else {
    return {
      'bgColor': Colors.grey[100],
      'txtColor': Colors.grey[800],
    };
  }
}

String toTitleCase(String str) {
  return str
      .replaceAllMapped(
          RegExp(
              r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
          (Match m) =>
              "${m[0][0].toUpperCase()}${m[0].substring(1).toLowerCase()}")
      .replaceAll(RegExp(r'(_|-)+'), ' ');
}

void showSnackBar(String txt, context) {
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(txt),
    ),
  );
}

List<Widget> generateLayout({
  @required List fields,
  @required ViewType viewType,
  bool editMode = true,
  bool withLabel = true,
}) {
  List<Widget> collapsibles = [];
  List<Widget> widgets = [];

  List<String> collapsibleLabels = [];

  bool collapsible = false;

  int idx = 0;

  fields.forEach((field) {
    var val = field["_current_val"] ?? field["default"];

    if (field["fieldtype"] == "Section Break") {
      if (field["collapsible"] == 1) {
        collapsibleLabels.add(field["label"]);
        if (collapsible == false) {
          collapsible = true;
        } else {
          var sectionVisibility = collapsibles.any((element) {
            if (element is Visibility) {
              return element.visible == true;
            } else {
              return true;
            }
          });
          widgets.add(Visibility(
            visible: sectionVisibility,
            child: ListTileTheme(
              contentPadding: EdgeInsets.all(0),
              child: CustomExpansionTile(
                maintainState: true,
                title: Text(
                  collapsibleLabels[idx].toUpperCase(),
                  style: Palette.dimTxtStyle,
                ),
                children: [...collapsibles],
              ),
            ),
          ));
          idx += 1;
          collapsibles.clear();
        }
      } else {
        collapsible = false;

        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Divider(
                color: Palette.darkGrey,
              ),
              field["label"] != null
                  ? Text(
                      field["label"].toUpperCase(),
                      style: Palette.dimTxtStyle,
                    )
                  : Container(),
            ],
          ),
        ));
      }
    } else if (collapsible == true) {
      if (viewType == ViewType.form) {
        collapsibles.add(Visibility(
          visible: editMode ? true : val != null && val != '',
          child: makeControl(field, val, withLabel, editMode),
        ));
      } else {
        collapsibles.add(
          makeControl(field, val, withLabel, editMode),
        );
      }
    } else {
      if (viewType == ViewType.form) {
        widgets.add(Visibility(
          visible: editMode ? true : val != null && val != '',
          child: makeControl(field, val, withLabel, editMode),
        ));
      } else {
        widgets.add(
          makeControl(field, val, withLabel, editMode),
        );
      }
    }
  });

  return widgets;
}

DateTime parseDate(val) {
  if (val == null) {
    return null;
  } else if (val == "Today") {
    return DateTime.now();
  } else {
    return DateTime.parse(val);
  }
}

Widget buildStatusButton(String doctype, String status) {
  return Container(
    width: 60,
    padding: EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: setStatusColor(doctype, status)['bgColor'],
      borderRadius: BorderRadius.circular(5),
    ),
    child: Center(
      child: Text(
        status ?? "",
        style: TextStyle(
          color: setStatusColor(doctype, status)['txtColor'],
          fontSize: 12,
        ),
      ),
    ),
  );
}
