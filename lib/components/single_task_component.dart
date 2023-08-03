import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:md_assistant/models/task.dart';

class SingleTaskComponent extends StatelessWidget {
  const SingleTaskComponent({super.key, required this.task, required this.isDailyTask});

  final Task task;
  final bool isDailyTask;

  @override
  Widget build(BuildContext context) {
    bool isTaskHaveDoneDateTime = task.doneDateTimeTimeStamp != null && task.doneDateTimeTimeStamp! > 0;
    resetDaily(isTaskHaveDoneDateTime);
    return ListTile(
      title: Text(
        task.name,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: task.notes.isEmpty ? null : Text(task.notes),
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (value) {
          log("task.doneDateTimeTimeStamp is ${task.doneDateTimeTimeStamp}");
          task.isCompleted = value!;
          if (task.isCompleted && !isTaskHaveDoneDateTime) {
            task.doneDateTimeTimeStamp = DateTime.now().millisecondsSinceEpoch;
          }
          task.save();
        },
      ),
      trailing: isDailyTask ? IconButton(icon: const Icon(Icons.delete), onPressed: () => task.delete()) : null,
    );
  }

  bool isAfterToday(int timestamp) {
    int compareResult = DateTime.now().toLocal().compareTo(DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal());
    return compareResult < 0;
  }

  Future<void> resetDaily(bool isTaskHaveDoneDateTime) async {
    if (!isDailyTask) {
      if (isTaskHaveDoneDateTime && isAfterToday(task.doneDateTimeTimeStamp!)) {
        task.isCompleted = false;
        task.doneDateTimeTimeStamp = null;
        await task.save();
      }
    }
  }
}
