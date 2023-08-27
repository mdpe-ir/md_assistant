import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:md_assistant/screens/ai_chat_screen.dart';
import 'package:md_assistant/screens/daily_tasks_screen.dart';
import 'package:md_assistant/screens/messagin_screen.dart';
import 'package:md_assistant/screens/settings_screen.dart';
import 'package:md_assistant/screens/tasks_screen.dart';

import 'screens/home_screen.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  int currentIndex = 0;
  List<Widget> pages = [
    HomeScreen(),
    MessaginScreen(),
    TasksScreen(),
    AiChatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'خانه',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.chatOutline),
            label: 'پیام رسان',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'کار های روزانه',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.robotOutline),
            label: 'چت بات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}
