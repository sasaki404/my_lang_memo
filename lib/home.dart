import 'package:flutter/material.dart';
import 'package:my_lang_memo/settings/settings_page.dart';
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
      appBar: AppBar(
        title: const Text(
          "Words & Sentences",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.black26,
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Text(
                'Menu',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.draw),
              title: const Text("Training",
                  style: TextStyle(fontWeight: FontWeight.w700)),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text("Playlist",
                  style: TextStyle(fontWeight: FontWeight.w700)),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings",
                  style: TextStyle(fontWeight: FontWeight.w700)),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return const SettingsPage();
                }));
              },
            ),
            const Divider(),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: WordsPage(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) {
              return WordRegistDialog();
            },
          );
        },
        backgroundColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }
}
