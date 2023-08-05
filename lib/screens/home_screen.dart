import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:md_assistant/components/add_daily_task_component.dart';
import 'package:md_assistant/components/sync_button_components.dart';
import 'package:md_assistant/models/task.dart';
import 'package:md_assistant/utils/constant.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../components/single_task_component.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.task_alt),
                text: "کار های امروز",
              ),
              Tab(
                icon: Icon(Icons.list),
                text: "لیست انجام کار",
              ),
            ],
          ),
          title: const Text('خانه'),
          actions: [
            SyncButtonComponents(isSendData: false),
            SyncButtonComponents(isSendData: true),
          ],
        ),
        body: TabBarView(
          children: [
            WatchBoxBuilder(
              box: Hive.box<Task>('tasks'),
              builder: (context, box) {
                final tasks = box.values.toList().cast<Task>();
                final currentDay = DateTime.now().weekday;
                final todayTasks = tasks.where((task) => task.day == _getDayOfWeek(currentDay)).toList();

                return ListView.builder(
                  itemCount: todayTasks.length,
                  itemBuilder: (context, index) {
                    final task = todayTasks[index];
                    return SingleTaskComponent(task: task, isDailyTask: false);
                  },
                );
              },
            ),
            Scaffold(
              body: WatchBoxBuilder(
                box: Hive.box<Task>('tasks'),
                builder: (context, box) {
                  final tasks = box.values.toList().cast<Task>();
                  const currentDay = Constant.daily;
                  final todayTasks = tasks.where((task) => task.day == currentDay).toList().reversed.toList();
                  return ListView.builder(
                    itemCount: todayTasks.length,
                    itemBuilder: (context, index) {
                      final task = todayTasks[index];
                      return SingleTaskComponent(task: task, isDailyTask: true);
                    },
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showMaterialModalBottomSheet(
                    enableDrag: true,
                    context: context,
                    builder: (context) => AddDailyTaskComponent(key: key),
                  );
                },
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayOfWeek(int dayNumber) {
    switch (dayNumber) {
      case 1:
        return Constant.monday;
      case 2:
        return Constant.tuesday;
      case 3:
        return Constant.wednesday;
      case 4:
        return Constant.thursday;
      case 5:
        return Constant.friday;
      case 6:
        return Constant.saturday;
      case 7:
        return Constant.sunday;
      default:
        return "";
    }
  }
}
