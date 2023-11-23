import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_lang_memo/database/word_table.dart';
import 'package:my_lang_memo/model/word.dart';
import 'package:my_lang_memo/web_view_page.dart';

class WordsPage extends ConsumerStatefulWidget {
  WordsPage({super.key});

  @override
  WordsPageState createState() => WordsPageState();
}

class WordsPageState extends ConsumerState<WordsPage> {
  Future<List<Word>>? wordRecords;
  final wordTable = WordTable();

  @override
  void initState() {
    super.initState();
    setState(() {
      wordRecords = wordTable.selectAll();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        color: Color.fromARGB(66, 63, 60, 60),
                        shape: const RoundedRectangleBorder(
                          // 枠線を変更できる
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60), // Card左上の角に丸み
                            bottomRight:
                                Radius.elliptical(40, 20), //Card左上の角の微調整
                            // (x, y) -> (元の角から左にどれだけ離れているか, 元の角から上にどれだけ離れているか)
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(record.value),
                            Text(record.meaning ?? ''),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: records.length,
                );
        });
  }
}
