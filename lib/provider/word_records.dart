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
    state = AsyncData(await WordTable().selectAll());
    return id;
  }

  Future<List<Word>> selectAll() async {
    return await WordTable().selectAll();
  }
}
