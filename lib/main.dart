import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:md_assistant/models/task.dart';
import 'package:md_assistant/screens/home_screen.dart';
import 'package:md_assistant/screens/settings_screen.dart';
import 'package:md_assistant/utils/hive_helper.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:window_manager/window_manager.dart';
import 'application.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (UniversalPlatform.isDesktop) {
    // Must add this line.
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(400, 620),
      maximumSize: Size(500, 720) ,
      center: true,
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await HiveHelper.initHive();
  await Hive.openBox<Task>('tasks');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Tasks Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          fontFamily: "Vazirmatn",
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fa', 'IR'), // Persian (Farsi) locale
      ],

      locale: const Locale('fa', 'IR'),
      // Set the initial locale to Persian (Farsi)
      routes: {
        '/': (_) => const Application(),
      },
    );
  }
}
