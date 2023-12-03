import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_lang_memo/provider/audio_speed.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  double _audioSpeed = 0.0; // 初期値

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.watch(audioSpeedNotifierProvider).when(
          data: (data) {
            setState(() {
              _audioSpeed = data;
            });
          },
          loading: CircularProgressIndicator.new,
          error: (error, stacktrace) => Text(error.toString()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.black26,
      ),
      body: Column(
        children: [
          Text(
            "Audio speed: $_audioSpeed",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: _audioSpeed,
            min: 0,
            max: 2,
            divisions: 20,
            onChanged: (value) async {
              setState(() {
                _audioSpeed = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(audioSpeedNotifierProvider.notifier)
                  .updateState(_audioSpeed);
            },
            child: const Text(
              "Save",
            ),
          ),
        ],
      ),
    );
  }
}
