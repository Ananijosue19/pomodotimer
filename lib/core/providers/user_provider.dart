import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserProvider with ChangeNotifier {
  int _xp = 0;
  int _streak = 0;
  int _totalPomodoros = 0;
  String? _lastSessionDate;
  final String _xpKey = 'pomotime_xp';
  final String _streakKey = 'pomotime_streak';
  final String _totalKey = 'pomotime_total_pomos';
  final String _lastDateKey = 'pomotime_last_date';

  int get xp => _xp;
  int get streak => _streak;
  int get totalPomodoros => _totalPomodoros;
  int get level => (_xp ~/ 1000) + 1;
  double get levelProgress => (_xp % 1000) / 1000;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt(_xpKey) ?? 0;
    _streak = prefs.getInt(_streakKey) ?? 0;
    _totalPomodoros = prefs.getInt(_totalKey) ?? 0;
    _lastSessionDate = prefs.getString(_lastDateKey);
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
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
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
    if (_lastSessionDate != null) {
      await prefs.setString(_lastDateKey, _lastSessionDate!);
    }
  }
}
