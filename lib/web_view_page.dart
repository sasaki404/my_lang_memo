import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class WebViewPage extends StatefulWidget {
  final String keyWord;
  const WebViewPage({super.key, required this.keyWord});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(
        Uri.parse(
            "https://www.deepl.com/ja/translator#en/ja/${widget.keyWord}"),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
