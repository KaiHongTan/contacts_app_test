import 'package:shared_preferences/shared_preferences.dart';

class TimeConfig {
  static const String _timeAgoPrefs = "setTimeAgo";

  static Future<bool> getTimeAgo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_timeAgoPrefs) ?? true;
  }

  static Future<bool> setTimeAgo(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_timeAgoPrefs, value);
  }
}