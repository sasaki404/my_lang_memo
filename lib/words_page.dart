import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:my_lang_memo/database/word_table.dart';
import 'package:my_lang_memo/model/word.dart';
import 'package:my_lang_memo/provider/audio_speed.dart';
import 'package:my_lang_memo/provider/word_records.dart';
import 'package:my_lang_memo/web_view_page.dart';
import 'package:my_lang_memo/word_regist_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class WordsPage extends ConsumerStatefulWidget {
  WordsPage({super.key});

  @override
  WordsPageState createState() => WordsPageState();
}

class WordsPageState extends ConsumerState<WordsPage> {
  late Future<List<Word>> wordRecords;
  final wordTable = WordTable();
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
    // レコードが登録・更新されたときの状態更新処理
    ref.listen(wordRecordsNotifierProvider, ((previous, next) {
      next.whenData((value) {
        setState(() {
          wordRecords = Future.value(value);
        });
      });
    }));

    tts.setLanguage('en-US');
    // 設定から再生速度を取得
    ref
        .watch(audioSpeedNotifierProvider)
        .whenData((value) => tts.setSpeechRate(value));
    ref.listen(audioSpeedNotifierProvider, ((previous, next) {
      next.whenData((value) {
        tts.setSpeechRate(value);
      });
    }));

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
                      onTapDown: (details) {
                        final position = details.globalPosition;
                        showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                              position.dx, position.dy, 0, 0),
                          items: [
                            // クリップボードにコピー
                            PopupMenuItem(
                              onTap: () async {
                                final data = ClipboardData(text: record.value);
                                await Clipboard.setData(data);
                              },
                              child: const Text('Copy to Clipboard'),
                            ),
                            // Google翻訳で開く
                            PopupMenuItem(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => WebViewPage(
                                      url:
                                          "https://translate.google.co.jp/?hl=ja&sl=en&tl=ja&text=${record.value}&op=translate",
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Open with google translate'),
                            ),
                            // DeepLで開く
                            PopupMenuItem(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => WebViewPage(
                                      url:
                                          "https://www.deepl.com/ja/translator#en/ja/${record.value}",
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Open with DeepL'),
                            ),
                            // Weblioで開く
                            PopupMenuItem(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => WebViewPage(
                                      url:
                                          "https://ejje.weblio.jp/content/${record.value}",
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Open with Weblio'),
                            ),
                            // 編集
                            PopupMenuItem(
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return WordRegistDialog(wordRecord: record);
                                  },
                                );
                              },
                              child: const Text('Edit'),
                            ),
                            // 発音
                            PopupMenuItem(
                              onTap: () {
                                tts.speak(record.value);
                              },
                              child: const Text('Pronounce'),
                            ),
                            // ChatGPT
                            PopupMenuItem(
                              onTap: () async {
                                if (!await launchUrl(
                                    Uri.parse("https://chat.openai.com/"))) {
                                  throw Exception('Could not launch');
                                }
                              },
                              child: const Text('ChatGPT'),
                            ),
                            // Add more menu items as needed
                          ],
                        );
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
                                child: const Icon(
                                  Icons.volume_up,
                                  size: 40,
                                ),
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
