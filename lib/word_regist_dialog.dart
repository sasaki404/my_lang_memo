import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator/translator.dart';
import 'package:my_lang_memo/camera_view.dart';
import 'package:my_lang_memo/model/word.dart';
import 'package:my_lang_memo/provider/word_records.dart';

class WordRegistDialog extends ConsumerStatefulWidget {
  final Word wordRecord;
  const WordRegistDialog({super.key, this.wordRecord = const Word(value: "")});

  @override
  WordRegistDialogState createState() => WordRegistDialogState();
}

class WordRegistDialogState extends ConsumerState<WordRegistDialog> {
  final valueController = TextEditingController();
  final meaningController = TextEditingController();
  bool? isFinished = false;
  int? type = 0;
  bool isEdit = false;
  late Word wordRecord;
  late final NavigatorState navigator;
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    navigator = Navigator.of(context);
    wordRecord = widget.wordRecord;
    if (wordRecord.value.isNotEmpty) {
      isEdit = true;
      wordRecord = widget.wordRecord;
      valueController.text = wordRecord.value;
      meaningController.text = wordRecord.meaning ?? "";
      isFinished = wordRecord.isFinished;
      type = wordRecord.type;
    }
  }

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
                      MaterialPageRoute(
                        builder: (context) {
                          return const CameraView(
                            isJapanese: false,
                          );
                        },
                      ),
                    ).then(
                      (value) {
                        if (value != null && value is String) {
                          // 改行文字を削除する
                          valueController.text = value.trimRight();
                        }
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
                suffixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return const CameraView(
                                isJapanese: true,
                              );
                            },
                          ),
                        ).then(
                          (value) {
                            if (value != null && value is String) {
                              // 改行文字を削除する
                              valueController.text = value.trimRight();
                            }
                          },
                        );
                      },
                      child: const Icon(
                        Icons.camera_alt,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (valueController.text.isEmpty) {
                          return;
                        }
                        final translation = await translator
                            .translate(valueController.text, to: 'ja');
                        meaningController.text = translation.text;
                      },
                      child: const Icon(
                        Icons.translate_sharp,
                      ),
                    ),
                  ],
                ),
              ),
              maxLines: 2,
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
            (isEdit)
                ? ElevatedButton(
                    onPressed: () async {
                      await ref
                          .watch(wordRecordsNotifierProvider.notifier)
                          .delete(wordRecord.id!);
                      navigator.pop();
                    },
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        Colors.black45,
                      ),
                    ),
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  )
                : const SizedBox(),
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
              FloatingActionButton(
                child: const CircularProgressIndicator(),
                onPressed: () {},
              );
              if (meaningController.text.isEmpty) {
                final translation =
                    await translator.translate(valueController.text, to: 'ja');
                meaningController.text = translation.text;
              }
              if (!isEdit) {
                await ref.watch(wordRecordsNotifierProvider.notifier).insert(
                      Word(
                        value: valueController.text,
                        meaning: meaningController.text,
                        isFinished: isFinished,
                        type: type,
                      ),
                    );
              } else {
                await ref
                    .watch(wordRecordsNotifierProvider.notifier)
                    .updateState(
                      Word(
                        id: wordRecord.id,
                        value: valueController.text,
                        meaning: meaningController.text,
                        isFinished: isFinished,
                        type: type,
                      ),
                    );
              }
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
