import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

import 'credentials.dart';

void main() => runApp(MyApp());

// void main() {
//   runApp(MaterialApp(
//     title: 'Add Credentials',
//     home: Profile(),
//   ));
// }

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credentials',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CredentialsList(),
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

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      title: new Text('Credentials'),
      actions: [
        searchBar.getSearchAction(context),
      ],
    );
  }

  _CredentialsListState() {
    searchBar = new SearchBar(
      inBar: true,
      setState: setState,
      onSubmitted: print,
      buildDefaultAppBar: buildAppBar,
    );
  }

  Widget _buildList() {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: _credentialsList.length,
        padding: EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          return _buildRow(_credentialsList[i], context, i);
        });
  }

  Widget _buildRow(Credentials credentials, BuildContext context, int i) {
    return ListTile(
      title: Text(
        credentials.accountName == null
            ? credentials.platform
            : "${credentials.platform}: ${credentials.accountName}",
        style: TextStyle(fontSize: 18.0),
      ),
      onTap: () {
        // if(_authenticate())
        _awaitProfile(context, credentials, i);
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
              )),
    );

    if (result != null) {
      setState(() {
        _credentialsList.add(Credentials.clone(result));
      });
    }
  }

  void _awaitProfile(
      BuildContext context, Credentials credentials, int i) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Profile(
            credentials: credentials,
            i: i,
          ),
        ));

    if (result != null) {
      setState(() {
        if (result[0] == 0) {
          _credentialsList[i] = Credentials.clone(result[1]);
        } else if (result[0] == 1) {
          _credentialsList.removeAt(i);
        }
      });
    }
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
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: searchBar.build(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
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
  AddCredentials({Key key, @required this.credentials}) : super(key: key);
  Credentials newCredentials;

  @override
  Widget build(BuildContext context) {
    // credentials = Credentials(null);
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
                      initialValue: credentials.accountName == null
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
                          newCredentials.accountName == ""
                              ? null
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
                      Navigator.pop(context, newCredentials);
                    }
                  },
                  child: Text(
                    'Confirm',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
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
  Credentials credentials;
  int i;
  Profile({Key key, @required this.credentials, @required this.i})
      : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  void empty() {}

  void _awaitAddCredentials(
      BuildContext context, Credentials credentials, int i) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddCredentials(
                credentials: credentials,
              )),
    );

    if (result != null) {
      setState(() {
        widget.credentials = Credentials.clone(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.credentials.platform),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, [0, widget.credentials]);
              }),
          actions: [
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _awaitAddCredentials(context, widget.credentials, widget.i);
                }),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  deleteCredentials(context);
                }),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.credentials.accountName == null
                    ? ""
                    : widget.credentials.accountName,
                style: TextStyle(
                    fontSize: widget.credentials.accountName == null ? 0 : 40,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: widget.credentials.accountName == null ? 0 : 40,
              ),
              Text(
                widget.credentials.username == null
                    ? ""
                    : widget.credentials.username,
                style: TextStyle(
                    fontSize: widget.credentials.username == null ? 0 : 30),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.credentials.password == null
                    ? ""
                    : widget.credentials.password,
                style: TextStyle(
                    fontSize: widget.credentials.password == null ? 0 : 30),
              ),
              SizedBox(
                height: widget.credentials.notes == null ||
                        widget.credentials.username == null &&
                            widget.credentials.password == null &&
                            widget.credentials.accountName == null
                    ? 0
                    : 35,
              ),
              Container(
                  // width: MediaQuery.of(context).size.width/
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.credentials.notes == null
                        ? ""
                        : widget.credentials.notes,
                    style: TextStyle(
                        fontSize: widget.credentials.notes == null ? 0 : 18),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ));
  }
}

void deleteCredentials(BuildContext context) {
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
      // Navigator.of(context).pop();
      Navigator.pop(context, [1, null]);
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
