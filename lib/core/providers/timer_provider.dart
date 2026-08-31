import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'task_provider.dart';
import 'user_provider.dart';
import '../services/notification_service.dart';

enum SessionType { focus, shortBreak, longBreak }

class TimerProvider with ChangeNotifier {
  TaskProvider? _taskProvider;
  UserProvider? _userProvider;

  void updateDependencies(TaskProvider tasks, UserProvider user) {
    _taskProvider = tasks;
    _userProvider = user;
  }

  // Durations in seconds
  int _workDuration = 25 * 60;
  int _shortBreakDuration = 5 * 60;
  int _longBreakDuration = 15 * 60;

  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  SessionType _currentSession = SessionType.focus;
  int _completedPomodorosInCycle = 0;
  bool _soundEnabled = true;
  Timer? _timer;

  // Keys for SharedPreferences
  final String _workKey = 'timer_work_duration';
  final String _shortKey = 'timer_short_break_duration';
  final String _longKey = 'timer_long_break_duration';
  final String _soundKey = 'timer_sound_enabled';

  TimerProvider() {
    _loadDurations();
  }

  int get workMinutes => _workDuration ~/ 60;
  int get shortBreakMinutes => _shortBreakDuration ~/ 60;
  int get longBreakMinutes => _longBreakDuration ~/ 60;
  int get completedPomodorosInCycle => _completedPomodorosInCycle;
  bool get soundEnabled => _soundEnabled;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  SessionType get currentSession => _currentSession;

  Future<void> _loadDurations() async {
    final prefs = await SharedPreferences.getInstance();
    _workDuration = (prefs.getInt(_workKey) ?? 25) * 60;
    _shortBreakDuration = (prefs.getInt(_shortKey) ?? 5) * 60;
    _longBreakDuration = (prefs.getInt(_longKey) ?? 15) * 60;
    _soundEnabled = prefs.getBool(_soundKey) ?? true;
    _resetToSessionDefault();
    notifyListeners();
  }

  Future<void> toggleSound(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
    notifyListeners();
  }

  Future<void> updateDurations({int? work, int? short, int? long}) async {
    final prefs = await SharedPreferences.getInstance();
    if (work != null) {
      _workDuration = work * 60;
      await prefs.setInt(_workKey, work);
    }
    if (short != null) {
      _shortBreakDuration = short * 60;
      await prefs.setInt(_shortKey, short);
    }
    if (long != null) {
      _longBreakDuration = long * 60;
      await prefs.setInt(_longKey, long);
    }
    resetTimer();
    notifyListeners();
  }

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
    
    if (_soundEnabled) {
      FlutterRingtonePlayer().playNotification();
    }

    if (_currentSession == SessionType.focus) {
      // Award XP
      _userProvider?.addXp(100);
      
      // Update task progress if a task is selected
      final selectedTask = _taskProvider?.selectedTask;
      if (selectedTask != null) {
        _taskProvider?.incrementCompletedPomodoro(selectedTask.id);
      }
      
      _completedPomodorosInCycle++;

      // Switch to long break every 4 pomodoros
      if (_completedPomodorosInCycle % 4 == 0) {
        _currentSession = SessionType.longBreak;
        NotificationService.showNotification(
          id: 1,
          title: "Session terminée !",
          body: "Bravo ! Il est temps pour une pause longue de $longBreakMinutes minutes.",
        );
      } else {
        _currentSession = SessionType.shortBreak;
        NotificationService.showNotification(
          id: 1,
          title: "Session terminée !",
          body: "Bravo ! Il est temps pour une pause courte de $shortBreakMinutes minutes.",
        );
      }
    } else {
      _currentSession = SessionType.focus;
      NotificationService.showNotification(
        id: 2,
        title: "La pause est finie !",
        body: "Prêt à vous replonger dans votre travail ?",
      );
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
