import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_lang_memo/home.dart';

void main() {
  const home = Home();
  final app = MaterialApp(
    home: home,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Murecho',
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  );
  runApp(ProviderScope(child: app));
}
