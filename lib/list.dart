import 'package:credentials_app/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'credentials.dart';
import 'profile.dart';
import 'settings.dart';
import 'authentication.dart';

class CredentialsList extends StatefulWidget {
  @override
  _CredentialsListState createState() => _CredentialsListState();
}

class _CredentialsListState extends State<CredentialsList> {
  SearchBar searchBar;
  String search;
  bool searching = false;

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
      actions: [
        searchBar.getSearchAction(context),
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
                itemBuilder: (context, i) {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int authMethod = prefs.getInt('authMethod') ?? -1;
    if (authMethod == -1) {
      setAuth(context);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddCredentials(
                credentials: Credentials(null),
                edit: false,
              )),
    );
    setState(() {});
  }

  void _awaitProfile(
      BuildContext context, String platform, String accountName) async {
    await authenticate();

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Profile(
            platform: platform,
            accountName: accountName,
          ),
        ));

    setState(() {});
  }

  void awaitSettings(BuildContext context) async {
    await authenticate();

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
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 117.0,
              child: DrawerHeader(
                child: Text(
                  'Credentials',
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
                awaitSettings(context);
              },
            ),
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
