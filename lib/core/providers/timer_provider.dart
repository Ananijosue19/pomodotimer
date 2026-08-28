import 'dart:async';
import 'package:flutter/material.dart';
import 'task_provider.dart';
import 'user_provider.dart';

enum SessionType { focus, shortBreak, longBreak }

class TimerProvider with ChangeNotifier {
  TaskProvider? _taskProvider;
  UserProvider? _userProvider;

  void updateDependencies(TaskProvider tasks, UserProvider user) {
    _taskProvider = tasks;
    _userProvider = user;
  }

  int _workDuration = 25 * 60; // 25 minutes in seconds
  int _shortBreakDuration = 5 * 60;
  int _longBreakDuration = 15 * 60;

  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  SessionType _currentSession = SessionType.focus;
  Timer? _timer;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  SessionType get currentSession => _currentSession;

  String get timerString {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    int total;
    switch (_currentSession) {
      case SessionType.focus:
        total = _workDuration;
        break;
      case SessionType.shortBreak:
        total = _shortBreakDuration;
        break;
      case SessionType.longBreak:
        total = _longBreakDuration;
        break;
    }
    return _remainingSeconds / total;
  }

  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    pauseTimer();
    _resetToSessionDefault();
    notifyListeners();
  }

  void _onTimerComplete() {
    pauseTimer();
    
    if (_currentSession == SessionType.focus) {
      // Award XP
      _userProvider?.addXp(100);
      
      // Update task progress if a task is selected
      final selectedTask = _taskProvider?.selectedTask;
      if (selectedTask != null) {
        _taskProvider?.incrementCompletedPomodoro(selectedTask.id);
      }
      
      _currentSession = SessionType.shortBreak;
    } else {
      _currentSession = SessionType.focus;
    }
    
    _resetToSessionDefault();
    notifyListeners();
  }

  void _resetToSessionDefault() {
    switch (_currentSession) {
      case SessionType.focus:
        _remainingSeconds = _workDuration;
        break;
      case SessionType.shortBreak:
        _remainingSeconds = _shortBreakDuration;
        break;
      case SessionType.longBreak:
        _remainingSeconds = _longBreakDuration;
        break;
    }
  }

  void setSessionType(SessionType type) {
    _currentSession = type;
    resetTimer();
  }
}
