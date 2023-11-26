import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator/translator.dart';
import 'package:my_lang_memo/camera_view.dart';
import 'package:my_lang_memo/model/word.dart';
import 'package:my_lang_memo/provider/word_records.dart';

class WordRegistDialog extends ConsumerStatefulWidget {
  const WordRegistDialog({super.key});

  @override
  WordRegistDialogState createState() => WordRegistDialogState();
}

class WordRegistDialogState extends ConsumerState<WordRegistDialog> {
  final valueController = TextEditingController();
  final meaningController = TextEditingController();
  bool? isFinished = false;
  int? type = 0;
  final translator = GoogleTranslator();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: valueController,
              decoration: InputDecoration(
                labelText: "word or sentence",
                border: const OutlineInputBorder(),
                suffixIcon: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        //遷移先の画面としてリスト追加画面を指定
                        return const CameraView();
                      }),
                    ).then(
                      (value) {
                        valueController.text = value;
                      },
                    );
                  },
                  child: const Icon(
                    Icons.camera_alt,
                  ),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: meaningController,
              decoration: InputDecoration(
                labelText: "meaning",
                border: const OutlineInputBorder(),
                suffixIcon: GestureDetector(
                  onTap: () async {
                    final translation = await translator
                        .translate(valueController.text, to: 'ja');
                    meaningController.text = translation.text;
                  },
                  child: const Icon(
                    Icons.translate_sharp,
                  ),
                ),
              ),
            ),
            DropdownButton(
              items: const [
                DropdownMenuItem(value: 0, child: Text("Word")),
                DropdownMenuItem(value: 1, child: Text("Idioms")),
                DropdownMenuItem(value: 2, child: Text("Sentence")),
              ],
              value: type,
              onChanged: (int? value) {
                setState(() {
                  type = value;
                });
              },
            ),
            const Text("learned"),
            Checkbox(
              value: isFinished,
              onChanged: (e) {
                setState(
                  () {
                    isFinished = e;
                  },
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(
              Colors.white,
            ),
          ),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (valueController.text == "") {
              // 値が入力されなかったときエラーダイアログを表示
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text("Error",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                      content: const Text("Please enter a name."),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "OK",
                          ),
                        ),
                      ],
                    );
                  });
            } else {
              if (meaningController.text.isEmpty) {
                final translation =
                    await translator.translate(valueController.text, to: 'ja');
                meaningController.text = translation.text;
              }
              await ref.watch(wordRecordsNotifierProvider.notifier).insert(Word(
                    value: valueController.text,
                    meaning: meaningController.text,
                    isFinished: isFinished,
                    type: type,
                  ));
              if (context.mounted) Navigator.pop(context, true);
            }
          },
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(
              Colors.white,
            ),
          ),
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
