import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String notes;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  String day;

  @HiveField(4)
  int? doneDateTimeTimeStamp;

  Task({required this.name, required this.notes, this.isCompleted = false, required this.day, this.doneDateTimeTimeStamp = 0});

  Map<String, dynamic> toMap() {
    return {'name': name, 'notes': notes, 'isCompleted': isCompleted, 'day': day, 'doneDateTimeTimeStamp': doneDateTimeTimeStamp};
  }

  // Convert the Map to Task object
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'],
      notes: map['notes'],
      isCompleted: map['isCompleted'] ?? false,
      day: map['day'],
      doneDateTimeTimeStamp: map['doneDateTimeTimeStamp'] ?? 0,
    );
  }
}
