import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_lang_memo/home.dart';

void main() {
  const home = Home();
  const app = MaterialApp(
    home: home,
    debugShowCheckedModeBanner: false,
  );
  runApp(const ProviderScope(child: app));
}
