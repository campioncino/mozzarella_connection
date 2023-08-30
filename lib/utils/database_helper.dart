

import 'dart:async';

import 'package:bufalabuona/utils/app_utils.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance =  DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null
    //&& _db!.isOpen
    ) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  Future<void> close() async{
    await _db!.close();
    _db = null;
  }

  Future<bool> isOpen() async {
    if (_db == null){
      return false;
    }
    return await _db!.isOpen;
  }

  DatabaseHelper.internal();

  initDb() async {
    String dbPath = await AppUtils.getDatabasePath();
    var theDb = await openDatabase(dbPath, version: 1, onCreate: _onCreate, onConfigure: _onConfigure);
    return theDb;
  }

  void _onCreate(Database db, int version) async {}

  _onConfigure(Database db) async {
    try {
      // await db.execute("PRAGMA journal_mode = DELETE");
    } catch (error) {}
  }
}
