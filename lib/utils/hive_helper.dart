import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:md_assistant/models/task.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class HiveHelper {
  static Future<void> initHive() async {
    String appDocumentDir = "";

    if (!kIsWeb) {
      final path = await path_provider.getApplicationDocumentsDirectory();
      appDocumentDir = path.path;
    }

    Hive.init(appDocumentDir);
    Hive.registerAdapter(TaskAdapter());
  }
}
