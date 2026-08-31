import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserProvider with ChangeNotifier {
  int _xp = 0;
  int _streak = 0;
  int _totalPomodoros = 0;
  String? _lastSessionDate;
  Map<String, int> _dailyHistory = {};

  final String _xpKey = 'pomotime_xp';
  final String _streakKey = 'pomotime_streak';
  final String _totalKey = 'pomotime_total_pomos';
  final String _lastDateKey = 'pomotime_last_date';
  final String _historyKey = 'pomotime_history';

  int get xp => _xp;
  int get streak => _streak;
  int get totalPomodoros => _totalPomodoros;
  int get level => (_xp ~/ 1000) + 1;
  double get levelProgress => (_xp % 1000) / 1000;

  Map<String, int> get dailyHistory => _dailyHistory;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt(_xpKey) ?? 0;
    _streak = prefs.getInt(_streakKey) ?? 0;
    _totalPomodoros = prefs.getInt(_totalKey) ?? 0;
    _lastSessionDate = prefs.getString(_lastDateKey);
    
    final historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      _dailyHistory = Map<String, int>.from(jsonDecode(historyJson));
    }

    _checkStreak();
    notifyListeners();
  }

  void _checkStreak() {
    if (_lastSessionDate == null) return;
    final lastDate = DateFormat('yyyy-MM-dd').parse(_lastSessionDate!);
    final today = DateTime.now();
    final difference = today.difference(lastDate).inDays;

    if (difference > 1) {
      _streak = 0;
      _saveUserData();
    }
  }

  Future<void> addXp(int amount) async {
    _xp += amount;
    _totalPomodoros++;
    
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    
    // Update history
    _dailyHistory[today] = (_dailyHistory[today] ?? 0) + 1;
    
    if (_lastSessionDate != today) {
      _streak++;
      _lastSessionDate = today;
    }
    
    await _saveUserData();
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_xpKey, _xp);
    await prefs.setInt(_streakKey, _streak);
    await prefs.setInt(_totalKey, _totalPomodoros);
    await prefs.setString(_historyKey, jsonEncode(_dailyHistory));
    if (_lastSessionDate != null) {
      await prefs.setString(_lastDateKey, _lastSessionDate!);
    }
  }

  List<double> getLast7DaysData() {
    List<double> data = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      data.add((_dailyHistory[dateStr] ?? 0).toDouble());
    }
    return data;
  }
}
