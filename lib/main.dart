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
//     home: Profile(),
//   ));
// }
// Future<void> getMode() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   isLightMode.add(prefs.getBool('lightMode') ?? true);
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
  var _credentialsList = <Credentials>[];
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

  // Widget _buildList() {
  //   return ListView.separated(
  //       separatorBuilder: (context, index) => Divider(),
  //       itemCount: _credentialsList.length,
  //       padding: EdgeInsets.all(16.0),
  //       itemBuilder: /*1*/ (context, i) {
  //         return _buildRow(_credentialsList[i], context, i);
  //       });
  // }

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
    0 = Pin
    1 = Biometric
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

  @override
  Widget build(BuildContext context) {
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
              title: Text('Print Data'),
              onTap: () {
                printData();
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
            ListTile(
              title: Text('Dark Mode'),
              onTap: () {
                // isLightMode.add(false);
                // _toggleDarkMode();
                DynamicTheme.of(context).setBrightness(
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark);
                // print(Theme.of(context).brightness);
              },
            ),
            // ListTile(
            //   title: Text('Light Mode'),
            //   onTap: () {
            //     isLightMode.add(true);
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
                    if (_formKey.currentState.validate()) {
                      newCredentials.accountName =
                          newCredentials.accountName == "" ||
                                  newCredentials.accountName == null
                              ? 'null'
                              : newCredentials.accountName;
                      newCredentials.username = newCredentials.username == ""
                          ? null
                          : newCredentials.username;
                      newCredentials.password = newCredentials.password == ""
                          ? null
                          : newCredentials.password;
                      newCredentials.notes = newCredentials.notes == ""
                          ? null
                          : newCredentials.notes;

                      if (!edit) {
                        db.saveCredentials(newCredentials);
                        Navigator.pop(context);
                      } else if (credentials.platform !=
                              newCredentials.platform ||
                          credentials.accountName !=
                              newCredentials.accountName) {
                        db.saveCredentials(newCredentials);
                        db.deleteCredentials(
                            credentials.platform, credentials.accountName);
                        Navigator.pop(context, newCredentials);
                      } else {
                        db.updateCredentials(newCredentials);
                        Navigator.pop(context);
                      }
                    }
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
