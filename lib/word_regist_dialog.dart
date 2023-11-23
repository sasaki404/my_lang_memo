import 'package:flutter/material.dart';
import 'package:my_lang_memo/database/word_table.dart';
import 'package:my_lang_memo/model/word.dart';

class WordRegistDialog extends StatefulWidget {
  const WordRegistDialog({super.key});
  @override
  State<WordRegistDialog> createState() => _WordRegistDialogState();
}

class _WordRegistDialogState extends State<WordRegistDialog> {
  final valueController = TextEditingController();
  final meaningController = TextEditingController();
  bool? isFinished = false;
  int? type = 0;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Input word or sentence!"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: valueController,
              decoration: const InputDecoration(
                  labelText: "word or sentence", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: valueController,
              decoration: const InputDecoration(
                  labelText: "meaning", border: OutlineInputBorder()),
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
          child: const Text("Cancel"),
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
                            child: const Text("OK")),
                      ],
                    );
                  });
            } else {
              await WordTable().insert(Word(
                value: valueController.text,
                meaning: meaningController.text,
                isFinished: isFinished,
                type: type,
              ));
              if (context.mounted) Navigator.pop(context, true);
            }
          },
          child: const Text("Ok"),
        ),
      ],
    );
  }
}
