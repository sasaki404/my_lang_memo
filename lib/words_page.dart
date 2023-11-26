import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:my_lang_memo/database/word_table.dart';
import 'package:my_lang_memo/model/word.dart';
import 'package:my_lang_memo/provider/word_records.dart';
import 'package:my_lang_memo/web_view_page.dart';

class WordsPage extends ConsumerStatefulWidget {
  WordsPage({super.key});

  @override
  WordsPageState createState() => WordsPageState();
}

class WordsPageState extends ConsumerState<WordsPage> {
  late Future<List<Word>> wordRecords;
  final wordTable = WordTable();
  // FlutterTtsのインスタンスを作成
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    setState(() {
      wordRecords = wordTable.selectAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    // レコードが登録されたときの状態更新処理
    ref.listen(wordRecordsNotifierProvider, ((previous, next) {
      next.whenData((value) {
        setState(() {
          wordRecords = Future.value(value);
        });
      });
    }));

    tts.setLanguage('en-US');
    tts.setSpeechRate(0.5);

    return FutureBuilder(
        future: wordRecords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data!;
          return (records.isEmpty)
              ? const Center(
                  child: Text(
                    'NO RECORD',
                  ),
                )
              : ListView.separated(
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    WebViewPage(keyWord: record.value)));
                      },
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                record.value,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Murecho',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              subtitle: (record.meaning != null)
                                  ? Text(
                                      record.meaning!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black54),
                                    )
                                  : const SizedBox(),
                              trailing: GestureDetector(
                                onTap: () {
                                  tts.speak(record.value);
                                },
                                child: const Icon(Icons.volume_up),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: records.length,
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 90,
                  ),
                );
        });
  }
}
