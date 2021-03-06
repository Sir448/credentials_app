import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'credentials.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database _db;
  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'credentials.db');

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE Credentials(platform TEXT, account_name TEXT, username TEXT, password TEXT, notes TEXT, PRIMARY KEY (platform, account_name))');
  }

  Future<int> saveCredentials(Credentials credentials) async {
    var dbClient = await db;
    var result = await dbClient.insert('Credentials', credentials.toMap());
    return result;
  }

  Future<List> getAllCredentials() async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(
      'Credentials',
      columns: ['platform', 'account_name'],
      orderBy: 'platform ASC, account_name ASC',
    );
    List<Credentials> credentials = <Credentials>[];
    result.forEach(
        (credential) => credentials.add(Credentials.fromMap(credential)));
    return credentials.toList();
  }

  Future<List> searchCredentials(String search) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(
      'Credentials',
      columns: ['platform', 'account_name'],
      where: 'platform LIKE ? or account_name LIKE ?',
      whereArgs: ['%$search%', '%$search%'],
      orderBy: 'platform ASC, account_name ASC',
    );

    if (result.isEmpty) return null;

    List<Credentials> credentials = <Credentials>[];
    result.forEach(
        (credential) => credentials.add(Credentials.fromMap(credential)));
    return credentials.toList();
  }

  Future<Credentials> getCredentials(
      String platform, String accountName) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(
      'Credentials',
      columns: ['platform', 'account_name', 'username', 'password', 'notes'],
      where: 'platform = ? and account_name = ?',
      whereArgs: [platform, accountName],
    );

    return result.isNotEmpty ? Credentials.fromMap(result.first) : null;
  }

  Future<bool> checkCredentials(String platform, String accountName) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(
      'Credentials',
      columns: ['platform'],
      where: 'platform = ? and account_name = ?',
      whereArgs: [platform, accountName == null ? 'null' : accountName],
      limit: 1,
    );

    return result.isEmpty;
  }

  Future<int> deleteCredentials(String platform, String accountName) async {
    var dbClient = await db;
    return await dbClient.delete(
      'Credentials',
      where: 'platform = ? and account_name = ?',
      whereArgs: [platform, accountName],
    );
  }

  Future<int> updateCredentials(Credentials credentials) async {
    var dbClient = await db;
    return await dbClient.update(
      'Credentials',
      credentials.toMap(),
      where: 'platform = ? and account_name = ?',
      whereArgs: [credentials.platform, credentials.accountName],
    );
  }

  Future<void> deleteTable() async {
    var dbClient = await db;
    dbClient.delete('Credentials');
  }

  Future<void> printPath() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'credentials.db');
    print(path);
  }

  Future<bool> tableEmpty() async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(
      'Credentials',
      columns: ['platform'],
      limit: 1,
    );
    return result.isEmpty;
  }
}
