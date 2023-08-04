import 'package:flutter/material.dart';
import 'package:md_assistant/main.dart';
import 'package:md_assistant/packages/auto_direction/auto_direction.dart';
import 'package:md_assistant/providers/secure_storage_provider.dart';
import 'package:md_assistant/utils/constant.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
          _item(
              title: "تم برنامه",
              icon: Icons.color_lens_outlined,
              actionWidget: DropdownButton<String>(
                value: _themeMode,
                onChanged: (value) {
                  setState(() {
                    _themeMode = value!;
                    _saveTheme(value);
                  });
                },
                items: <String>['system', 'light', 'dark'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )),
          _item(
              title: "کلید شخصی چت بات",
              icon: Icons.key,
              actionWidget: TextButton(
                  onPressed: () async {
                    String? value = await SecureStorageProvider.getString(key: Constant.bingChatSecretKey);
                    TextEditingController textController = TextEditingController(text: value);
                    if (mounted) {
                      showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Material(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: AutoDirection(
                                      text: textController.text,
                                      child: TextFormField(
                                        controller: textController,
                                        decoration: const InputDecoration(
                                          labelText: 'کلید شخصی چت بات',
                                          hintText: "کلید  شخصی فعال ساز چت بات را وارد کنید ",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              await SecureStorageProvider.setString(
                                                  key: Constant.bingChatSecretKey, value: textController.text);
                                              if (mounted) Navigator.pop(context);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
                                              child: Text("ثبت"),
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
                                              child: Text("لغو"),
                                            )),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: const Text("ثبت کلید"))),
        ],
      ),
    );
  }

  Widget _item({required IconData icon, required String title, required Widget actionWidget , Widget? subTitle}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: subTitle,
          subtitleTextStyle: TextStyle(fontSize: 13 , fontFamily: "Vazirmatn"),
          trailing: actionWidget,
        ),
        const Divider(),
      ],
    );
  }
}
