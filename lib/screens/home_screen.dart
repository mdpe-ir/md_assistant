import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:md_assistant/models/task.dart';
import 'package:md_assistant/utils/constant.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('کار های امروز'),
      ),
      body: WatchBoxBuilder(
        box: Hive.box<Task>('tasks'),
        builder: (context, box) {
          final tasks = box.values.toList().cast<Task>();
          final currentDay = DateTime.now().weekday;
          final todayTasks = tasks
              .where((task) => task.day == _getDayOfWeek(currentDay))
              .toList();

          return ListView.builder(
            itemCount: todayTasks.length,
            itemBuilder: (context, index) {
              final task = todayTasks[index];
              return ListTile(
                title: Text(task.name),
                subtitle: task.notes.isEmpty ? null :  Text(task.notes),
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    task.isCompleted = value!;
                    task.save();
                  },
                ),
              );
            },
          );
        },
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
