import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:credentials_app/database_helper.dart';

import 'credentials.dart';

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
