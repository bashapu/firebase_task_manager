import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

extension PriorityExtension on TaskPriority {
  String get name {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }
}

class Task {
  String id;
  String name;
  bool isCompleted;
  TaskPriority priority;
  DateTime dueDate;

  Task({
    required this.id,
    required this.name,
    required this.isCompleted,
    required this.priority,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'isCompleted': isCompleted,
        'priority': priority.index,
        'dueDate': dueDate.toIso8601String(),
      };

  factory Task.fromMap(String id, Map<String, dynamic> data) => Task(
        id: id,
        name: data['name'],
        isCompleted: data['isCompleted'],
        priority: TaskPriority.values[data['priority']],
        dueDate: DateTime.parse(data['dueDate']),
      );
}