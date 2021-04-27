import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import 'package:credentials_app/database_helper.dart';

class Settings extends StatefulWidget {
  bool tableEmpty;
  Settings({Key key, @required this.tableEmpty}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  LocalAuthentication auth = LocalAuthentication();
  bool isSwitched = false;
  int dropdownValue = 0;
  bool tableEmpty = false;

  void empty() {}

  void deleteAllCredentials(BuildContext context, DatabaseHelper db) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget deleteAllButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
        var db = new DatabaseHelper();
        db.deleteTable();
        print("Deleted");
        widget.tableEmpty = true;
        tableEmpty = true;
        setState(() {});
      },
      child: Text("Delete All"),
    );

    AlertDialog alert = AlertDialog(
      title: Text("Delete All Credentials"),
      content: Text(
          "Are you sure you would like to delete all credentials? This cannot be undone."),
      actions: [
        cancelButton,
        deleteAllButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void deleteAll(BuildContext context) async {
    var db = new DatabaseHelper();
    deleteAllCredentials(context, db);
  }

  @override
  Widget build(BuildContext context) {
    isSwitched = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<List>(
        future: Future.wait(
            [auth.getAvailableBiometrics(), SharedPreferences.getInstance()]),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            dropdownValue = snapshot.data[1].getInt('authMethod');
          }
          List<DropdownMenuItem<int>> _menuItems;

          if (snapshot.hasData && snapshot.data[0].isNotEmpty) {
            _menuItems = [
              DropdownMenuItem(
                child: Text("None"),
                value: 0,
              ),
              DropdownMenuItem(
                child: Text("Pin"),
                value: 1,
              ),
              DropdownMenuItem(
                child: Text(snapshot.data[0].contains(BiometricType.fingerprint)
                    ? "Fingerprint"
                    : "Face"),
                value: 2,
              ),
            ];
          } else {
            _menuItems = [
              DropdownMenuItem(
                child: Text("None"),
                value: 0,
              ),
              DropdownMenuItem(
                child: Text("Pin"),
                value: 1,
              ),
            ];
          }

          return Scaffold(
            appBar: AppBar(
              title: Text("Settings"),
            ),
            body: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Dark Mode",
                        style: TextStyle(fontSize: 20),
                      ),
                      Switch(
                        value: isSwitched,
                        onChanged: (value) {
                          setState(() {
                            isSwitched = value;
                            EasyDynamicTheme.of(context).changeTheme();
                          });
                        },
                        activeTrackColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? null
                                : Colors.lightBlueAccent,
                        activeColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? null
                                : Colors.blue,
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: DropdownButton<int>(
                    value: dropdownValue,
                    iconSize: 40,
                    elevation: 16,
                    underline: Container(
                      height: 2,
                      color: Colors.blue,
                    ),
                    onChanged: (int newValue) {
                      setState(() {
                        dropdownValue = newValue;
                        snapshot.data[1].setInt('authMethod', newValue);
                      });
                    },
                    items: _menuItems,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  height: 60,
                  child: ElevatedButton(
                    onPressed: widget.tableEmpty || tableEmpty
                        ? null
                        : () {
                            deleteAll(context);
                          },
                    child: Text("Delete All Credentials"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red[600],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
