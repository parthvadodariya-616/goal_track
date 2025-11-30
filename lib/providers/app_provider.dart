import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/goal_model.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  
  List<Goal> _goals = [];
  Map<String, int> _completionHistory = {}; 
  int _coins = 0; 
  ThemeMode _themeMode = ThemeMode.system;
  DateTime _dashboardFocusedDate = DateTime.now();

  // --- TIMER STATE ---
  Goal? _activeGoal;
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  bool _isPaused = false;
  
  // --- FOCUS MODE STATE ---
  bool _isFocusModeActive = false;

  // Getters
  List<Goal> get goals => _goals;
  int get coins => _coins;
  ThemeMode get themeMode => _themeMode;
  DateTime get dashboardFocusedDate => _dashboardFocusedDate;
  Goal? get activeGoal => _activeGoal;
  Duration get remainingTime => _remainingTime;
  bool get isPaused => _isPaused;
  bool get isFocusModeActive => _isFocusModeActive;
  bool get isOnBreak => false; 

  // --- Persistence ---
  Future<void> loadData() async {
    await NotificationService.init(); 
    try {
      String? storedGoals = await _storage.read(key: 'goals_data');
      if (storedGoals != null) {
        List<dynamic> decoded = jsonDecode(storedGoals);
        _goals = decoded.map((item) => Goal.fromJson(item)).toList();
      }
      String? storedHistory = await _storage.read(key: 'history_data');
      if (storedHistory != null) {
        Map<String, dynamic> decodedMap = jsonDecode(storedHistory);
        _completionHistory = decodedMap.map((key, value) => MapEntry(key, value as int));
      }
      String? storedCoins = await _storage.read(key: 'user_coins');
      _coins = int.parse(storedCoins ?? '0');
      
      String? storedTheme = await _storage.read(key: 'app_theme');
      if (storedTheme == 'dark') _themeMode = ThemeMode.dark;
      if (storedTheme == 'light') _themeMode = ThemeMode.light;
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
    notifyListeners();
  }

  Future<void> _saveData() async {
    await _storage.write(key: 'goals_data', value: jsonEncode(_goals.map((e) => e.toJson()).toList()));
    await _storage.write(key: 'history_data', value: jsonEncode(_completionHistory));
    await _storage.write(key: 'user_coins', value: _coins.toString());
  }

  // --- ACTIONS ---
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _storage.write(key: 'app_theme', value: _themeMode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  void toggleFocusMode(bool status) {
    _isFocusModeActive = status;
    notifyListeners();
  }

  void setDashboardDate(DateTime date) {
    _dashboardFocusedDate = date;
    notifyListeners();
  }

  // --- TIMER LOGIC ---
  void startGoalSession(Goal goal) {
    if (_activeGoal != null) stopGoalSession();
    _activeGoal = goal;
    _isPaused = false;
    
    final now = DateTime.now();
    if (goal.date.isAfter(now)) {
      _remainingTime = goal.date.difference(now);
    } else {
      _remainingTime = const Duration(minutes: 30);
    }
    _startTimerTick();
    notifyListeners();
  }

  void _startTimerTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;
      if (_remainingTime.inSeconds > 0) {
        _remainingTime -= const Duration(seconds: 1);
        NotificationService.showTimerNotification(
          title: "Focusing: ${_activeGoal?.title}",
          body: _formatDuration(_remainingTime),
          isPaused: false
        );
      } else {
        stopGoalSession();
        NotificationService.showTimerNotification(
          title: "Time's Up!", 
          body: "Goal time reached.",
          isPaused: true
        );
      }
      notifyListeners();
    });
  }

  void pauseGoalSession() {
    _isPaused = true;
    NotificationService.showTimerNotification(
      title: "Paused: ${_activeGoal?.title}",
      body: _formatDuration(_remainingTime),
      isPaused: true
    );
    notifyListeners();
  }

  void resumeGoalSession() {
    _isPaused = false;
    notifyListeners();
  }

  void stopGoalSession() {
    _timer?.cancel();
    _activeGoal = null;
    _remainingTime = Duration.zero;
    _isPaused = false;
    NotificationService.cancelNotification();
    notifyListeners();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  // --- CRUD ---
  void addGoal(String title, DateTime dateTime, Color color) {
    _goals.insert(0, Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: dateTime,
      colorValue: color.value,
    ));
    _saveData();
    notifyListeners();
  }

  void updateGoal(String id, String newTitle, DateTime newDate, Color newColor) {
    final index = _goals.indexWhere((x) => x.id == id);
    if (index != -1) {
      Goal old = _goals[index];
      _goals[index] = Goal(id: old.id, title: newTitle, date: newDate, colorValue: newColor.value, isCompleted: old.isCompleted);
      _saveData();
      notifyListeners();
    }
  }

  void removeGoal(String id) {
    _goals.removeWhere((x) => x.id == id);
    _saveData();
    notifyListeners();
  }

  void restoreGoal(Goal goal) {
    _goals.insert(0, goal);
    _saveData();
    notifyListeners();
  }

  void rescheduleGoal(String id, DateTime newDate) {
    int index = _goals.indexWhere((g) => g.id == id);
    if(index != -1) {
      Goal old = _goals[index];
      _goals[index] = Goal(id: old.id, title: old.title, isCompleted: old.isCompleted, colorValue: old.colorValue, date: newDate);
      _saveData();
      notifyListeners();
    }
  }

  void toggleGoalStatus(String id) {
    final index = _goals.indexWhere((x) => x.id == id);
    if (index != -1) {
      _goals[index].isCompleted = !_goals[index].isCompleted;
      DateTime now = DateTime.now();
      String dateKey = "${now.year}-${now.month}-${now.day}";
      if (_goals[index].isCompleted) {
        _coins += 10; 
        _completionHistory[dateKey] = _goals[index].colorValue;
      } else {
        _coins = (_coins - 10).clamp(0, 999999);
        Goal? other = _goals.cast<Goal?>().firstWhere((g) => g != null && g.isCompleted && g.date.year == now.year && g.date.month == now.month && g.date.day == now.day, orElse: () => null);
        if (other != null) {
          _completionHistory[dateKey] = other.colorValue;
        } else {
          _completionHistory.remove(dateKey);
        }
      }
      _saveData();
      notifyListeners();
    }
  }

  Color? getColorForDate(DateTime date) {
    String key = "${date.year}-${date.month}-${date.day}";
    if (_completionHistory.containsKey(key)) return Color(_completionHistory[key]!);
    return null;
  }

  List<Goal> getOverdueGoals() {
    DateTime now = DateTime.now();
    return _goals.where((g) => !g.isCompleted && g.date.isBefore(now)).toList();
  }
}