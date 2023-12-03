import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel {
  static const String audioSpeedKey = 'audio_speed';
  double _audioSpeed = 0.5;
  double get audioSpeed => _audioSpeed;

  Future<void> getSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final speed = prefs.getDouble(audioSpeedKey) ?? 0.5;
    _audioSpeed = speed;
  }

  Future<double> getAudioSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    _audioSpeed = prefs.getDouble(audioSpeedKey) ?? 0.5;
    return _audioSpeed;
  }

  Future<void> setAudioSpeed(double speed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(audioSpeedKey, speed);
    _audioSpeed = speed;
  }
}
