import 'dart:io';

import 'package:flutter_hub/data/TagModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    //se o database for nulo então é criada uma nova instancia
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TAGBRAINN.db");

    String sqlTag =
        "CREATE TABLE Tag (id INTEGER PRIMARY KEY, nmTag TEXT, nmUsuario TEXT, nmRepositorio TEXT)";

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute(sqlTag);
    });
  }

  Future<List<TagModel>> getTags() async {
    final db = await database;
    var res = await db.query("Tag");
    List<TagModel> list =
        res.isNotEmpty ? res.map((c) => TagModel.fromMap(c)).toList() : [];

    return list;
  }

    Future<int> getQtdTags() async {
    var db = await database;
    // para pegarmos a contagem temos que ir na SQFlite e utilizar o firstIntValue
    return Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM Tag"));
  }
  


  Future<int> newTag(TagModel newTag) async {
    final db = await database;
    //get the biggest id in the table
    var table =
        await db.rawQuery("SELECT MAX(ifnull(id,0))+1 as id FROM Tag");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Tag (id, nmTag, nmUsuario, nmRepositorio)"
        " VALUES (?,?,?,?)",
        [id, newTag.nmTag, newTag.nmUsuario, newTag.nmRepositorio]);
    return id;
  }
}
