import 'package:hive/hive.dart';
import 'package:md_assistant/models/task.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class HiveHelper {
  static Future<void> initHive() async {
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(TaskAdapter());
  }
}
