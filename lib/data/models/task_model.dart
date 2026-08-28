import 'package:uuid/uuid.dart';

class TaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final int estimatedPomodoros;
  final int completedPomodoros;

  TaskModel({
    String? id,
    required this.title,
    this.isCompleted = false,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
  }) : id = id ?? const Uuid().v4();

  TaskModel copyWith({
    String? title,
    bool? isCompleted,
    int? estimatedPomodoros,
    int? completedPomodoros,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
      estimatedPomodoros: json['estimatedPomodoros'],
      completedPomodoros: json['completedPomodoros'],
    );
  }
}
