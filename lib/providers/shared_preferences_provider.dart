import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider {
  SharedPreferencesProvider._();

  static late SharedPreferences _preferences;

  static String getString(String key, {String defaultValue = ''}) {
    return _preferences.getString(key) ?? defaultValue;
  }

  static Future<bool> setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  static Future<void> initSharedPreferencesProvider() async {
    final preferences = await SharedPreferences.getInstance();
    _preferences = preferences;
  }
}
