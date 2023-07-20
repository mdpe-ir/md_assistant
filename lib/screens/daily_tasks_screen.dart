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
        title: Text("تنظیم کار های روزانه"),
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
    final tasksBox = await Hive.openBox<Task>('tasks');
    dayTasks = tasksBox.values.where((task) => task.day == widget.day).toList();
    setState(() {});
  }

  void _addTask() {
    setState(() {
      dayTasks.add(Task(name: '', notes: '', day: widget.day));
    });
  }

  void _deleteTask(int index) {
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
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
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
                decoration: InputDecoration(
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
                decoration: InputDecoration(
                  labelText: 'نوت',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteTask(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final tasksBox = await Hive.openBox<Task>('tasks');
          await tasksBox.clear(); // Clear previous tasks for this day
          for (final task in dayTasks) {
            task.day = widget.day;
            await tasksBox.add(task);
          }
          Navigator.pop(context);
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
