import 'package:my_lang_memo/database/database_manager.dart';
import 'package:my_lang_memo/model/word.dart';
import 'package:sqflite/sqflite.dart';

class WordTable {
  final tableName = 'WORD_TABLE';

  Future<void> create(Database db) async {
    final sql = """
      CREATE TABLE IF NOT EXISTS $tableName (
        "id" INTEGER NOT NULL,
        "value" TEXT NOT NULL,
        "meaning" TEXT,
        "type" INTEGER NOT NULL DEFAULT 0,
        "is_finished" INTEGER NOT NULL DEFAULT 0,
        "created_at" INTEGER NOT NULL DEFAULT (cast(strftime('%s', 'now') as integer)),
        "updated_at" INTEGER,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
    """;
    await db.execute(sql);
  }

  Future<int> insert(Word word) async {
    final db = await DatabaseManager().database;
    final sql = '''
      INSERT INTO $tableName (value, meaning, type, is_finished, created_at) VALUES (?, ?, ?, ?, ?)
    ''';
    return await db.rawInsert(sql, [
      word.value,
      word.meaning ?? "",
      word.type,
      word.isFinished,
      DateTime.now().millisecondsSinceEpoch
    ]);
  }

  Future<void> update(Word word) async {
    final db = await DatabaseManager().database;
    final sql = '''
        UPDATE $tableName set value = ?, meaning = ?, type = ?, is_finished = ?, updated_at = ? WHERE id = ?
    ''';
    await db.rawQuery(sql, [
      word.value,
      word.meaning ?? "",
      word.type,
      word.isFinished,
      DateTime.now().millisecondsSinceEpoch,
      word.id
    ]);
  }

  Future<List<Word>> selectAll() async {
    final db = await DatabaseManager().database;
    final sql = '''
        SELECT * from $tableName
    ''';
    final res = await db.rawQuery(sql);
    return res.map((e) => Word.fromSqfliteDatabase(e)).toList();
  }

  Future<void> delete(int id) async {
    final db = await DatabaseManager().database;
    final sql = '''
      DELETE FROM $tableName WHERE id = ?
    ''';
    await db.rawDelete(sql, [id]);
  }
}
