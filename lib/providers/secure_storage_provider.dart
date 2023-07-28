import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageProvider {
  SecureStorageProvider._();

  static late FlutterSecureStorage _flutterSecureStorage;

  static setString({required String key, required String value}) async {
    await _flutterSecureStorage.write(key: key, value: value);
  }

  static Future<String?> getString({required String key}) async {
    return await _flutterSecureStorage.read(key: key);
  }

  static Future<void> deleteString({required String key}) async {
    return await _flutterSecureStorage.delete(key: key);
  }

  static Future<void> initSecureStorageProvider() async {
    AndroidOptions _getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
        );
    _flutterSecureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions());
  }
}
