import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum TaskCategory {
  travail(name: 'Travail', color: Colors.blue),
  etudes(name: 'Études', color: Colors.purple),
  personnel(name: 'Personnel', color: Colors.green),
  autre(name: 'Autre', color: Colors.grey);

  final String name;
  final Color color;
  const TaskCategory({required this.name, required this.color});
}

class TaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final TaskCategory category;

  TaskModel({
    String? id,
    required this.title,
    this.isCompleted = false,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.category = TaskCategory.autre,
  }) : id = id ?? const Uuid().v4();

  TaskModel copyWith({
    String? title,
    bool? isCompleted,
    int? estimatedPomodoros,
    int? completedPomodoros,
    TaskCategory? category,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
      'category': category.index,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
      estimatedPomodoros: json['estimatedPomodoros'],
      completedPomodoros: json['completedPomodoros'],
      category: TaskCategory.values[json['category'] ?? TaskCategory.autre.index],
    );
  }
}
