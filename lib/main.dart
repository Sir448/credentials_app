import 'dart:async';

import 'package:credentials_app/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:sqflite_sqlcipher/sql.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:local_auth/local_auth.dart';

import 'package:dynamic_theme/dynamic_theme.dart';

import 'credentials.dart';

// StreamController<bool> isLightMode = StreamController();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

// void main() {
//   runApp(MaterialApp(
//     title: 'Add Credentials',
//     // theme: ThemeData.dark(),
//     home: Settings(),
//   ));
// }

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return new DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        primarySwatch: Colors.blue,
        // primaryColor: Colors.black,
        brightness: brightness,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: brightness == Brightness.dark ? Colors.black : null,
        ),
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          title: 'Credentials',
          theme: theme,
          home: CredentialsList(),
        );
      },
    );
  }
}

class CredentialsList extends StatefulWidget {
  @override
  _CredentialsListState createState() => _CredentialsListState();
}

class _CredentialsListState extends State<CredentialsList> {
  // var _credentialsList = <Credentials>[];
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  SearchBar searchBar;
  String search;
  bool searching = false;

  // void _toggleDarkMode() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool lightMode = prefs.getBool('lightMode') ?? true;
  //   isLightMode.add(!lightMode);
  //   prefs.setBool('lightMode', !lightMode);
  // }

  void empty() {}
  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      title: new Text(
        searching ? search : 'Credentials',
        style: searching
            ? TextStyle(fontSize: 16, fontWeight: FontWeight.w400)
            : null,
      ),
      leading: searching
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                searching = false;
                setState(() {});
              })
          : null,
      // leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: empty),
      actions: [
        searchBar.getSearchAction(context),
        // IconButton(icon: Icon(Icon.), onPressed: empty)
      ],
    );
  }

  _CredentialsListState() {
    searchBar = new SearchBar(
      inBar: true,
      setState: setState,
      onSubmitted: (value) {
        searching = true;
        search = value;
        setState(() {});
      },
      buildDefaultAppBar: buildAppBar,
    );
  }

  Widget _buildList() {
    var db = new DatabaseHelper();
    return FutureBuilder<List>(
        future:
            searching ? db.searchCredentials(search) : db.getAllCredentials(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          Widget child;
          if (snapshot.hasData && snapshot.data.isNotEmpty) {
            child = ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: snapshot.data.length,
                padding: EdgeInsets.all(16.0),
                itemBuilder: /*1*/ (context, i) {
                  return _buildRow(snapshot.data[i], context, i);
                });
          } else {
            child = Container();
          }
          return child;
        });
  }

  Widget _buildRow(Credentials credentials, BuildContext context, int i) {
    return ListTile(
      title: Text(
        credentials.accountName == "null"
            ? credentials.platform
            : "${credentials.platform}: ${credentials.accountName}",
        style: TextStyle(fontSize: 18.0),
      ),
      onTap: () {
        // if(_authenticate())
        _awaitProfile(context, credentials.platform, credentials.accountName);
      },
    );
  }

  void _awaitAddCredentials(BuildContext context) async {
    /*
    0 = None
    1 = Pin
    2 = Biometric
    */

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddCredentials(
                credentials: Credentials(null),
                edit: false,
              )),
    );
    setState(() {});
    // if (result != null) {
    //   setState(() {
    //     _credentialsList.add(Credentials.clone(result));
    //   });
    // }
  }

  void _awaitProfile(
      BuildContext context, String platform, String accountName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int authMethod = prefs.getInt('authMethod');
    if (authMethod == 1) {
    } else if (authMethod == 2) {
      final LocalAuthentication auth = LocalAuthentication();
      bool canCheckBiometrics;
      try {
        canCheckBiometrics = await auth.canCheckBiometrics;
      } on PlatformException catch (e) {
        print(e);
      }
      if (canCheckBiometrics) {
        bool authenticated = false;
        try {
          authenticated = await auth.authenticateWithBiometrics(
              localizedReason: "Please verify to view credentials");
        } on PlatformException catch (e) {
          print(e);
        }
        if (!mounted || !authenticated) return;
      }
    }

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Profile(
            platform: platform,
            accountName: accountName,
          ),
        ));

    setState(() {});
    // if (result != null) {
    //   setState(() {
    //     if (result[0] == 0) {
    //       _credentialsList[i] = Credentials.clone(result[1]);
    //     } else if (result[0] == 1) {
    //       _credentialsList.removeAt(i);
    //     }
    //   });
    // }
  }

  void printData() async {
    var db = new DatabaseHelper();
    List<Credentials> credentials = await db.getAllCredentials();
    credentials.forEach((element) {
      print(element);
    });
    print("Done printing");
  }

  void deleteTable() async {
    var db = new DatabaseHelper();
    db.deleteTable();
    print("Deleted");
    setState(() {});
  }

  void printPath() async {
    var db = new DatabaseHelper();
    db.printPath();
  }

  void _awaitSettings(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int authMethod = prefs.getInt('authMethod');
    if (authMethod == 1) {
    } else if (authMethod == 2) {
      final LocalAuthentication auth = LocalAuthentication();
      bool canCheckBiometrics;
      try {
        canCheckBiometrics = await auth.canCheckBiometrics;
      } on PlatformException catch (e) {
        print(e);
      }
      if (canCheckBiometrics) {
        bool authenticated = false;
        try {
          authenticated = await auth.authenticateWithBiometrics(
              localizedReason: "Please verify to view credentials");
        } on PlatformException catch (e) {
          print(e);
        }
        if (!mounted || !authenticated) return;
      }
    }
    var db = new DatabaseHelper();
    bool tableEmpty = await db.tableEmpty();
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Settings(
                tableEmpty: tableEmpty,
              )),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    /*Placeholder */
    setAuth(context);
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 117.0,
              child: DrawerHeader(
                child: Text(
                  'Warning - None of these work yet',
                  style: TextStyle(color: Colors.white),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.blue,
                ),
              ),
            ),
            ListTile(
              title: Text("Settings"),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => Settings()),
                // );
                _awaitSettings(context);
              },
            ),
            ListTile(
              title: Text('Print Data'),
              onTap: () {
                // printData();
                setAuth(context);
              },
            ),
            ListTile(
              title: Text('Delete Table'),
              onTap: () {
                deleteTable();
              },
            ),
            ListTile(
              title: Text('Print Path'),
              onTap: () {
                printPath();
              },
            ),
            // ListTile(
            //   title: Text('Dark Mode'),
            //   onTap: () {
            //     // isLightMode.add(false);
            //     // _toggleDarkMode();
            //     DynamicTheme.of(context).setBrightness(
            //         Theme.of(context).brightness == Brightness.dark
            //             ? Brightness.light
            //             : Brightness.dark);
            //     // print(Theme.of(context).brightness);
            //   },
            // ),
          ],
        ),
      ),
      appBar: searchBar.build(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          _awaitAddCredentials(context);
          // setAuth(context);
        },
      ),
      body: _buildList(),
    );
  }
}

class AddCredentials extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  Credentials credentials;
  bool edit;
  AddCredentials({Key key, @required this.credentials, @required this.edit})
      : super(key: key);
  Credentials newCredentials;
  bool existingCredential = false;

  void checkCredentials(
      DatabaseHelper db, String platform, String accountName) async {
    existingCredential = await db.checkCredentials(platform, accountName);
  }

  void submitCredentials(DatabaseHelper db, BuildContext context,
      String platform, String accountName) async {
    existingCredential = await db.checkCredentials(platform, accountName);
    if (_formKey.currentState.validate()) {
      newCredentials.accountName =
          newCredentials.accountName == "" || newCredentials.accountName == null
              ? 'null'
              : newCredentials.accountName;
      newCredentials.username =
          newCredentials.username == "" ? null : newCredentials.username;
      newCredentials.password =
          newCredentials.password == "" ? null : newCredentials.password;
      newCredentials.notes =
          newCredentials.notes == "" ? null : newCredentials.notes;

      if (!edit) {
        /*Placeholder */
        db.saveCredentials(newCredentials);
        Navigator.pop(context);
      } else if (credentials.platform != newCredentials.platform ||
          credentials.accountName != newCredentials.accountName) {
        db.saveCredentials(newCredentials);
        db.deleteCredentials(credentials.platform, credentials.accountName);
        Navigator.pop(context, newCredentials);
      } else {
        db.updateCredentials(newCredentials);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var db = new DatabaseHelper();
    newCredentials = Credentials.clone(credentials);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Credentials'),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: TextFormField(
                      style: TextStyle(fontSize: 18),
                      initialValue: credentials.platform == null
                          ? null
                          : credentials.platform,
                      decoration: InputDecoration(
                        hintText: 'Platform',
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (String value) {
                        newCredentials.platform = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Must have platform';
                        } else if (!existingCredential) {
                          return 'Duplicate account';
                        }
                        return null;
                      },
                    ),
                    width: MediaQuery.of(context).size.width * 3 / 7,
                    height: 40,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    child: TextFormField(
                      style: TextStyle(fontSize: 18),
                      initialValue: credentials.accountName == "null"
                          ? null
                          : credentials.accountName,
                      decoration: InputDecoration(
                        hintText: 'Account Name',
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (String value) {
                        newCredentials.accountName = value;
                        // checkCredentials(db, newCredentials.platform,
                        //     newCredentials.accountName);
                        // existingCredential = await db.checkCredentials(
                        //     newCredentials.platform,
                        //     newCredentials.accountName);
                      },
                      validator: (value) {
                        if (!existingCredential) {
                          return 'Duplicate account';
                        }
                        return null;
                      },
                    ),
                    width: MediaQuery.of(context).size.width * 3 / 7,
                    height: 40,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: TextFormField(
                      style: TextStyle(fontSize: 18),
                      initialValue: credentials.username == null
                          ? null
                          : credentials.username,
                      decoration: InputDecoration(
                        hintText: 'Username',
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (String value) {
                        newCredentials.username = value;
                      },
                    ),
                    width: MediaQuery.of(context).size.width * 3 / 7,
                    height: 40,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    child: TextFormField(
                      style: TextStyle(fontSize: 18),
                      initialValue: credentials.password == null
                          ? null
                          : credentials.password,
                      decoration: InputDecoration(
                        hintText: 'Password',
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (String value) {
                        newCredentials.password = value;
                      },
                    ),
                    width: MediaQuery.of(context).size.width * 3 / 7,
                    height: 40,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: TextFormField(
                  style: TextStyle(fontSize: 14),
                  initialValue:
                      credentials.notes == null ? null : credentials.notes,
                  decoration: InputDecoration(
                    hintText: 'Notes',
                  ),
                  textAlign: TextAlign.center,
                  onChanged: (String value) {
                    newCredentials.notes = value;
                  },
                ),
                width: MediaQuery.of(context).size.width * 3 / 5,
                height: 40,
              ),
              SizedBox(
                height: 40,
              ),
              SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    submitCredentials(db, context, newCredentials.platform,
                        newCredentials.accountName);
                  },
                  child: Text(
                    'Confirm',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    primary: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : null,
                  ),
                ),
                width: MediaQuery.of(context).size.width / 2,
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Profile extends StatefulWidget {
  String platform;
  String accountName;
  Profile({Key key, @required this.platform, @required this.accountName})
      : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  void empty() {}

  void _awaitAddCredentials(
      BuildContext context, Credentials credentials) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddCredentials(
                credentials: credentials,
                edit: true,
              )),
    );

    if (result != null) {
      widget.platform = result.platform;
      widget.accountName = result.accountName;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var db = new DatabaseHelper();
    return FutureBuilder<Credentials>(
      future: db.getCredentials(widget.platform, widget.accountName),
      builder: (BuildContext context, AsyncSnapshot<Credentials> snapshot) {
        Widget child;
        if (snapshot.hasData) {
          child = Scaffold(
              appBar: AppBar(
                title: Text(snapshot.data.platform),
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      // Navigator.pop(context, [0, widget.credentials]);
                      Navigator.pop(context);
                    }),
                actions: [
                  IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _awaitAddCredentials(context, snapshot.data);
                      }),
                  IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteCredentials(context, snapshot.data.platform,
                            snapshot.data.accountName, db);
                      }),
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      snapshot.data.accountName == "null"
                          ? ""
                          : snapshot.data.accountName,
                      style: TextStyle(
                          fontSize:
                              snapshot.data.accountName == "null" ? 0 : 40,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: snapshot.data.accountName == "null" ? 0 : 40,
                    ),
                    Text(
                      snapshot.data.username == null
                          ? ""
                          : snapshot.data.username,
                      style: TextStyle(
                          fontSize: snapshot.data.username == null ? 0 : 30),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      snapshot.data.password == null
                          ? ""
                          : snapshot.data.password,
                      style: TextStyle(
                          fontSize: snapshot.data.password == null ? 0 : 30),
                    ),
                    SizedBox(
                      height: snapshot.data.notes == null ||
                              snapshot.data.username == null &&
                                  snapshot.data.password == null &&
                                  snapshot.data.accountName == null
                          ? 0
                          : 35,
                    ),
                    Container(
                        // width: MediaQuery.of(context).size.width/
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          snapshot.data.notes == null
                              ? ""
                              : snapshot.data.notes,
                          style: TextStyle(
                              fontSize: snapshot.data.notes == null ? 0 : 18),
                          textAlign: TextAlign.center,
                        )),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ));
        } else {
          child = Container();
        }
        return child;
      },
    );
  }
}

// void deleteCredentials(BuildContext context, String platform,
//     String accountName, DatabaseHelper db,
//     {bool all = false, bool tableEmpty}) {
//   Widget cancelButton = TextButton(
//     child: Text("Cancel"),
//     onPressed: () {
//       Navigator.of(context).pop();
//     },
//   );

//   Widget deleteButton = TextButton(
//     child: Text("Delete"),
//     onPressed: () {
//       Navigator.of(context).pop();
//       Navigator.of(context).pop();
//       db.deleteCredentials(platform, accountName);
//       // Navigator.pop(context, [1, null]);
//     },
//   );

//   Widget deleteAllButton = TextButton(
//     onPressed: () {
//       Navigator.of(context).pop();
//       // Navigator.pop(context, true);
//       var db = new DatabaseHelper();
//       db.deleteTable();
//       print("Deleted");
//       tableEmpty = true;

//     },
//     child: Text("Delete All"),
//   );

//   AlertDialog alert = AlertDialog(
//     title: Text(all ? "Delete All Credentials" : "Delete Credentials"),
//     content: Text(all
//         ? "Are you sure you would like to delete all credentials? This cannot be undone."
//         : "Are you sure you would like to delete these credentials?"),
//     actions: [
//       cancelButton,
//       all ? deleteAllButton : deleteButton,
//     ],
//   );

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return alert;
//     },
//   );
// }

void deleteCredentials(BuildContext context, String platform,
    String accountName, DatabaseHelper db) {
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  Widget deleteButton = TextButton(
    child: Text("Delete"),
    onPressed: () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      db.deleteCredentials(platform, accountName);
      // Navigator.pop(context, [1, null]);
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text("Delete Credentials"),
    content: Text("Are you sure you would like to delete these credentials?"),
    actions: [
      cancelButton,
      deleteButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

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
        // Navigator.pop(context, true);
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
    // print("test 1");
    var db = new DatabaseHelper();
    deleteAllCredentials(context, db);
  }

  @override
  Widget build(BuildContext context) {
    isSwitched = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<List>(
        // future: auth.getAvailableBiometrics(),
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
                            DynamicTheme.of(context).setBrightness(isSwitched
                                ? Brightness.dark
                                : Brightness.light);
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
                        // print(newValue);
                        // print(snapshot.)
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
                      // primary: Theme.of(context).brightness == Brightness.dark
                      //     ? Colors.black
                      //     : null,
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

Future<void> setAuth(BuildContext context) async {
  final _formKey = GlobalKey<FormState>();
  final LocalAuthentication auth = LocalAuthentication();
  int pin;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.clear();

  List<BiometricType> availableBiometrics;
  try {
    availableBiometrics = await auth.getAvailableBiometrics();
  } on PlatformException catch (e) {
    print(e);
  }
  // if (!mounted) return;

  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  Widget enterButton = TextButton(
    child: Text("Enter"),
    onPressed: () {
      if (_formKey.currentState.validate()) {
        prefs.setInt('authMethod', 0);
        prefs.setInt('pin', pin);
        Navigator.of(context).pop();
      }
    },
  );

  AlertDialog setPin = AlertDialog(
    title: Text("Set Pin"),
    content: Form(
      key: _formKey,
      child: TextFormField(
        style: TextStyle(fontSize: 20),
        decoration: InputDecoration(
          hintText: 'Pin',
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value.isEmpty) {
            return 'Cannot be empty';
          } else if (int.tryParse(value) == null) {
            return 'Must be numbers only';
          }
          return null;
        },
        onChanged: (value) {
          pin = int.tryParse(value);
        },
      ),
    ),
    actions: [
      cancelButton,
      enterButton,
    ],
  );

  Widget noneButton = TextButton(
    child: Text("None"),
    onPressed: () {
      prefs.setInt('authMethod', 0);
      Navigator.of(context).pop();
      // showDialog(
      //     context: context,
      //     barrierDismissible: false,
      //     builder: (BuildContext context) {
      //       return setPin;
      //     });
    },
  );

  Widget pinButton = TextButton(
    child: Text("Pin"),
    onPressed: () {
      prefs.setInt('authMethod', 1);
      Navigator.of(context).pop();
      // showDialog(
      //     context: context,
      //     barrierDismissible: false,
      //     builder: (BuildContext context) {
      //       return setPin;
      //     });
    },
  );

  Widget biometricButton = TextButton(
    child: Text(availableBiometrics.contains(BiometricType.fingerprint)
        ? "Fingerprint"
        : "Face"),
    onPressed: () {
      prefs.setInt('authMethod', 2);
      Navigator.of(context).pop();
    },
  );

  AlertDialog chooseAuth = AlertDialog(
    title: Text("Choose Authentication Type"),
    // context: Te
    actions: [
      noneButton,
      pinButton,
      availableBiometrics.isNotEmpty ? biometricButton : null,
    ],
  );

  // if (availableBiometrics.isEmpty) {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return setPin;
  //       });
  // } else {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return chooseAuth;
  //       });
  // }
  // int authMethod = prefs.getInt('authMethod');
  // print(authMethod == 0
  //     ? "None"
  //     : authMethod == 1
  //         ? "Pin"
  //         : "Biometric");
  if (prefs.getInt('authMethod') == null) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return chooseAuth;
        });
  }
  // print(prefs.getInt('test'));
}
