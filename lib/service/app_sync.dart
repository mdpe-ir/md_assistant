import 'dart:convert';
import 'dart:developer';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:hive/hive.dart';
import 'package:md_assistant/utils/constant.dart';
import '../models/task.dart';
import 'google_client.dart';

class AppSync {
  static Future<void> syncApplicationData(String authKey, bool isSendData) async {
    log("authKey is ${json.decode(authKey)}");
    final authKeyMap = json.decode(authKey) as Map<String, dynamic>;
    final authKeyMapStr = authKeyMap.map((key, value) => MapEntry<String, String>(key, value.toString()));
    final authenticateClient = GoogleAuthClient(authKeyMapStr);
    final driveApi = drive.DriveApi(authenticateClient);

    final filesList = await driveApi.files.list(
      q: "name contains  '${Constant.googleDriveTaskSyncFileName}'",
      orderBy: "modifiedTime desc",
    );
    final file = await driveApi.files.get(filesList.files?.first.id ?? "");
    if (file.runtimeType == drive.File) {
      drive.File backupFile = file as drive.File;
      if (isSendData) {
        saveSyncData(driveApi, id: backupFile.id);
      } else {
        getSyncData(driveApi, backupFile.id!);
      }
    } else {
      if (isSendData) {
        saveSyncData(driveApi);
      }
    }
  }

  static saveSyncData(drive.DriveApi driveApi, {String? id}) async {
    final hiveData = await exportHiveDatabase();
    final Stream<List<int>> mediaStream = Future.value(hiveData).asStream().asBroadcastStream();
    var media = drive.Media(mediaStream, hiveData.length);
    var driveFile = drive.File();
    driveFile.name = "md_assistant_tasks.json";
    if (id != null) {
      await driveApi.files.update(driveFile, id, uploadMedia: media);
    } else {
      await driveApi.files.create(driveFile, uploadMedia: media);
    }
  }

  static getSyncData(drive.DriveApi driveApi, String id) async {
    try {
      final fileContent = await driveApi.files.get(id, downloadOptions: drive.DownloadOptions.fullMedia);
      if (fileContent.runtimeType == drive.Media) {
        drive.Media media = fileContent as drive.Media;
        List<int> bytes = [];
        await for (var chunk in media.stream) {
          bytes.addAll(chunk);
        }
        String content = utf8.decode(bytes);
        await importHiveDatabase(content);
      }

      // String content = utf8.decode(base64.decode(fileContent.to));
    } catch (e) {}
  }

  static Future<List<int>> exportHiveDatabase() async {
    final hiveBox = await Hive.openBox<Task>('tasks');
    final List<Map<String, dynamic>> dataToExport = hiveBox.values.map((task) => task.toMap()).toList();
    final jsonStr = json.encode(dataToExport); // Convert the data to a JSON string
    final encodedData = utf8.encode(jsonStr);
    return encodedData;
  }

  static Future importHiveDatabase(String content) async {
    final List<dynamic> dataToImport = json.decode(content);
    final hiveBox = await Hive.openBox<Task>('tasks');
    await hiveBox.clear();
    for (final item in dataToImport) {
      await hiveBox.add(Task.fromMap(item));
    }
  }
}
