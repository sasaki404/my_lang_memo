import 'package:my_lang_memo/settings/settings_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'audio_speed.g.dart';

@riverpod
class AudioSpeedNotifier extends _$AudioSpeedNotifier {
  @override
  Future<double> build() async {
    return await SettingsModel().getAudioSpeed();
  }

  // 状態を更新する
  Future<void> updateState(double speed) async {
    await SettingsModel().setAudioSpeed(speed);
    state = AsyncData(speed);
  }
}
