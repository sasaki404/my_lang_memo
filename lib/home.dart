import 'package:flutter/material.dart';
import 'package:my_lang_memo/word_regist_dialog.dart';
import 'package:my_lang_memo/words_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: WordsPage(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (_) {
              return WordRegistDialog();
            },
          );
          // Check if the result is true, meaning a new record was added
          if (result == true) {
            // Refresh the WordsPage by calling setState
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
