import 'package:my_lang_memo/database/word_table.dart';
import 'package:my_lang_memo/model/word.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'word_records.g.dart';

@riverpod
class WordRecordsNotifier extends _$WordRecordsNotifier {
  @override
  Future<List<Word>> build() async {
    return WordTable().selectAll();
  }

  Future<int> insert(Word word) async {
    int id = await WordTable().insert(word);
    // TODO: 全件取得する必要はない
    state = AsyncData(await WordTable().selectAll());
    return id;
  }

  Future<void> updateState(Word info) async {
    await WordTable().update(info);
    // TODO: 全件取得する必要はない
    state = AsyncData(await WordTable().selectAll());
  }

  Future<List<Word>> selectAll() async {
    return await WordTable().selectAll();
  }

  Future<void> delete(int id) async {
    await WordTable().delete(id);
    // TODO: 全件取得する必要はない
    state = AsyncData(await WordTable().selectAll());
  }
}
