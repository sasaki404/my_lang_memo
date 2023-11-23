import 'package:my_lang_memo/database/word_table.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseManager {
  Database? _database;

  // databaseのゲッター
  Future<Database> get database async {
    if (_database != null) {
      // databaseが作成済みのとき
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  // databaseのパスのゲッター
  Future<String> get fullPath async {
    const name = 'my_lang_app.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> _initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      // https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_db.md#prevent-database-locked-issue
      singleInstance: true,
    );
    return database;
  }

  // テーブルを追加したら、ここに追記
  Future<void> create(Database db, int ver) async {
    WordTable().create(db);
  }
}
