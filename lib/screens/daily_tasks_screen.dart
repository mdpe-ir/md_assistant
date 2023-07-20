import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:md_assistant/models/task.dart';
import 'package:md_assistant/utils/constant.dart';

class DailyTasksScreen extends StatelessWidget {
  final List<String> daysOfWeek = [
    Constant.saturday,
    Constant.sunday,
    Constant.monday,
    Constant.tuesday,
    Constant.wednesday,
    Constant.thursday,
    Constant.friday,
  ];

  DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تنظیم کار های روزانه"),
      ),
      body: ListView.builder(
        itemCount: daysOfWeek.length,
        itemBuilder: (context, index) {
          final day = daysOfWeek[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: ListTile(
                title: Text(day),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DayTasksScreen(day: day),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class DayTasksScreen extends StatefulWidget {
  final String day;

  DayTasksScreen({super.key, required this.day});

  @override
  _DayTasksScreenState createState() => _DayTasksScreenState();
}

class _DayTasksScreenState extends State<DayTasksScreen> {
  List<Task> dayTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    log('Loading tasks...');
    final tasksBox = await Hive.openBox<Task>('tasks');
    setState(() {
      dayTasks =
          tasksBox.values.where((task) => task.day == widget.day).toList();
    });
  }

  Future<void> _addTask() async {
    setState(() {
      dayTasks.add(Task(name: '', notes: '', day: widget.day));
    });
  }

  Future<void> _deleteTask(int index, Task task) async {
    final tasksBox = await Hive.openBox<Task>('tasks');
    await tasksBox.delete(task.key);
    setState(() {
      dayTasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day),
        actions: [
          IconButton(
            onPressed: _addTask,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        key: UniqueKey(),
        itemCount: dayTasks.length,
        itemBuilder: (context, index) {
          final task = dayTasks[index];
          return ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: task.name,
                onChanged: (value) {
                  task.name = value;
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
                maxLines: null,
                minLines: 1,
                initialValue: task.notes,
                onChanged: (value) {
                  task.notes = value;
                },
                decoration: const InputDecoration(
                  labelText: 'نوت',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteTask(index, task),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final tasksBox = await Hive.openBox<Task>('tasks');
          for (final task in dayTasks) {
            task.day = widget.day;
            if (task.key == null) {
              tasksBox.add(task);
            } else {
              tasksBox.put(task.key, task);
            }
          }
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
