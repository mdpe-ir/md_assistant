import 'package:flutter/material.dart';
import 'package:md_assistant/application.dart';
import 'package:md_assistant/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = prefs.getString('theme') ?? 'system';
    });
  }

  void _saveTheme(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', value);

    if (value == 'dark') {
      MyApp.of(context)!.changeTheme(ThemeMode.dark);
    }

    if (value == 'light') {
      MyApp.of(context)!.changeTheme(ThemeMode.light);
    }

    if (value == 'system') {
      MyApp.of(context)!.changeTheme(ThemeMode.system);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('تم برنامه'),
            // TODO: Add DropDownButton to change theme : Light , Dark, System
            trailing: DropdownButton<String>(
              value: _themeMode,
              onChanged: (value) {
                setState(() {
                  _themeMode = value!;
                  _saveTheme(value);
                });
              },
              items: <String>['system', 'light', 'dark']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
