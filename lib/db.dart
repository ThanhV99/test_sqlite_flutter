import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'ClientModel.dart';

// implementation (lazy loading)
class DBProvider{
  DBProvider._(); //constructort
  static final DBProvider db = DBProvider._(); // instance

  static Database? _database;
  static const String ID = "id";
  static const String FIRST_NAME = "first_name";
  static const String LAST_NAME = "last_name";
  static const String BLOCKED = "blocked";
  static const String TABLE = 'Client';
  static const String DB_NAME = 'TestDB.db';

  Future<Database> get database async{
    if(_database != null){
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }

  initDB() async{
    String path = join(await getDatabasesPath(), DB_NAME);
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE $TABLE (
          $ID INTEGER PRIMARY KEY,
          $FIRST_NAME TEXT,
          $LAST_NAME TEXT,
          $BLOCKED BIT
          )
          ''');
        }
    );
  }

  //them client moi
  insertClient(Client client) async{
    var dbClient = await database;
    client.id = await dbClient.insert("Client", client.toMap());
    return client;
  }

  //get client by id
  getClient(int id) async{
    final db = await database;
    var res = await db.query(TABLE, where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Client.fromMap(res.first) : null;
  }

  //get client blocked = 1
  getBlockedClients() async{
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM Client WHERE BLOCKED=1");
    List<Client>? list = res.isNotEmpty ? res.map((e) => Client.fromMap(e)).toList() : null;
    return list;
  }
  
  //get all client
  Future<List<Client>> getAllClient() async{
    final db = await database;
    var res = await db.query(TABLE);
    List<Client> list = res.isNotEmpty ? res.map((e) => Client.fromMap(e)).toList() : [];
    return list;
  }

  // update client theo id
  updateClient(Client newClient) async {
    final db = await database;
    return await db.update("Client", newClient.toMap(),
        where: "id = ?", whereArgs: [newClient.id]);
  }

  //block hoac unblock 1 client
  blockOrUnblock(Client client) async {
    final db = await database;
    Client blocked = Client(
        id: client.id,
        firstName: client.firstName,
        lastName: client.lastName,
        blocked: !client.blocked);
    var res = await db.update("Client", blocked.toMap(),
        where: "id = ?", whereArgs: [client.id]);
    return res;
  }

  // xoa 1 dong theo last_name
  deleteClient(String last_name) async{
    final db = await database;
    db.delete(TABLE, where: "last_name = ?", whereArgs: [last_name]);
  }

  deleteClientID(int id) async{
    final db = await database;
    db.delete(TABLE, where: "id = ?", whereArgs: [id]);
  }

  // xoa tat ca
  deleteAll() async{
    final db = await database;
    db.rawDelete("Delete * from $TABLE");
  }
}