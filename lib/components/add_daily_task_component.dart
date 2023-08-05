import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:md_assistant/utils/constant.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../models/task.dart';

class AddDailyTaskComponent extends StatefulWidget {
  const AddDailyTaskComponent({super.key});

  @override
  State<AddDailyTaskComponent> createState() => _AddDailyTaskComponentState();
}

class _AddDailyTaskComponentState extends State<AddDailyTaskComponent> {
  Task task = Task(name: "", notes: "", day: Constant.daily);
  TextEditingController noteController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: task.name,
                  onChanged: (value) {
                    setState(() => task.name = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'نام تسک',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: noteController,
                  maxLines: null,
                  minLines: 1,
                  onChanged: (value) {
                    setState(() => task.notes = value);
                  },
                  decoration:  InputDecoration(
                    suffix: IconButton(
                        onPressed: () async {
                          var picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (mounted) {
                            String? label = picked?.persianFormat(context);
                            setState(() => task.notes = label ?? "");
                            noteController.text = task.notes;
                          }
                        },
                        icon: Icon(Icons.calendar_month)),
                    labelText: 'یادداشت / ساعت انجام کار',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0,right: 16.0, bottom: 8),
                    child: TextButton(
                      child: Text("افزودن"),
                      onPressed: () async {
                        final tasksBox = await Hive.openBox<Task>('tasks');
                        await tasksBox.add(task);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
