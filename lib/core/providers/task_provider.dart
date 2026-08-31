import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  String? _selectedTaskId;
  final String _storageKey = 'pomotime_tasks';

  List<TaskModel> get tasks => _tasks;
  TaskModel? get selectedTask =>
      _selectedTaskId != null ? _tasks.firstWhere((t) => t.id == _selectedTaskId) : null;

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(_storageKey);
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      _tasks = decoded.map((item) => TaskModel.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void addTask(String title, {int estimatedPomodoros = 1, TaskCategory category = TaskCategory.autre}) {
    final newTask = TaskModel(
      title: title, 
      estimatedPomodoros: estimatedPomodoros,
      category: category,
    );
    _tasks.add(newTask);
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      _saveTasks();
      notifyListeners();
    }
  }

  void selectTask(String? id) {
    _selectedTaskId = id;
    notifyListeners();
  }

  void incrementCompletedPomodoro(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        completedPomodoros: _tasks[index].completedPomodoros + 1,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    if (_selectedTaskId == id) _selectedTaskId = null;
    _saveTasks();
    notifyListeners();
  }
}
